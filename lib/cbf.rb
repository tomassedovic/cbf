require 'parsers/aeolus_v0'
require 'generators/heat'

# converter_paths = File.join(File.dirname(__FILE__), 'converters', '*.rb')
# Dir.glob(converter_paths).each { |file| require file}


module CBF

  class InvalidFormat < StandardError; end

  class StringParameter
    def initialize(name, default_value)
      @name = name
      @default_value = default_value
    end

    attr_reader :name, :default_value
  end

  class PasswordParameter < StringParameter; end

  class ReferenceParameter
    def initialize(name, resource, parameter)
      @name = name
      @resource = resource
      @parameter = parameter
    end

    attr_reader :name, :resource, :parameter
  end

  class FileURL
    def initialize(url, name=nil, owner='root', group='root', mode='000644')
      @url = url
      if name
        @name = name
      else
        @name = File.basename(URI.parse(url).path)
      end
      @owner = owner
      @group = group
      @mode = mode
    end

    attr_reader :url, :name, :owner, :group, :mode
  end

  class FileContents
    def initialize(name, contents, owner='root', group='root', mode='000644')
      @name = name
      @contents = contents
      @owner = owner
      @group = group
      @mode = mode
    end

    attr_reader :name, :contents, :owner, :group, :mode
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
      raise InvalidFormat, format
    end
  end

  def self.get_generator(format)
    if GENERATORS.include? format
      GENERATORS[format]
    else
      raise InvalidFormat, format
    end
  end

  def self.parse(format, input_data, options={})
    get_parser(format).parse(input_data, options)
  end

  def self.generate(format, template)
    get_generator(format).generate(template)
  end

end