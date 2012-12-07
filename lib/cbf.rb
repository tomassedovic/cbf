require 'parsers/aeolus_v0'
require 'generators/heat'

# converter_paths = File.join(File.dirname(__FILE__), 'converters', '*.rb')
# Dir.glob(converter_paths).each { |file| require file}


module CBF

  class UnknownFormatError < StandardError; end
  class SyntaxError < StandardError; end
  class ValidationError < StandardError; end


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