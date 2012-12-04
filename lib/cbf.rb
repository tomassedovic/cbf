require 'parsers/aeolus_v0'
require 'generators/heat'

# converter_paths = File.join(File.dirname(__FILE__), 'converters', '*.rb')
# Dir.glob(converter_paths).each { |file| require file}


module CBF

  class UnknownFormatError < StandardError; end
  class SyntaxError < StandardError; end
  class ValidationError < StandardError; end

  class StringParameter
    def initialize(name, service_name, default_value)
      @name = name
      @service_name = service_name
      @default_value = default_value
    end

    attr_reader :name, :service_name, :default_value
  end

  class PasswordParameter < StringParameter; end

  class ReferenceParameter
    def initialize(name, service_name, resource, parameter)
      @name = name
      @service_name = service_name
      @resource = resource
      @parameter = parameter
    end

    attr_reader :name, :service_name, :resource, :parameter
  end

  class FileURL
    def initialize(url, location, name=nil, owner='root', group='root', mode='000644')
      @url = url
      if name
        @name = name
      else
        @name = File.basename(URI.parse(url).path)
      end
      @location = location
      @owner = owner
      @group = group
      @mode = mode
      @environment = []
    end

    attr_reader :url, :location, :name, :owner, :group, :mode
    attr_accessor :environment
  end

  class FileContents
    def initialize(name, contents, location, owner='root', group='root', mode='000644')
      @name = name
      @contents = contents
      @location = location
      @owner = owner
      @group = group
      @mode = mode
      @environment = []
    end

    attr_reader :name, :contents, :location, :owner, :group, :mode
    attr_accessor :environment
  end


  PARSERS = {
      :aeolus => Parsers::AeolusV0,
      :aeolus_v0 => Parsers::AeolusV0,
    }

  GENERATORS = {
      :heat => Generators::Heat,
      :cloud_formation => Generators::Heat,
  }

  def self.parsers()
    PARSERS.keys
  end

  def self.generators()
    GENERATORS.keys
  end

  def self.get_parser(format)
    if PARSERS.include? format
      PARSERS[format]
    else
      raise UnknownFormatError, format
    end
  end

  def self.get_generator(format)
    if GENERATORS.include? format
      GENERATORS[format]
    else
      raise UnknownFormatError, format
    end
  end

  def self.parse(format, input_data, options={})
    get_parser(format).parse(input_data, options)
  end

  def self.generate(format, template)
    get_generator(format).generate(template)
  end

end