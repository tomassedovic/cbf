require 'converters/aeolus_v0'
require 'converters/heat'

# converter_paths = File.join(File.dirname(__FILE__), 'converters', '*.rb')
# Dir.glob(converter_paths).each { |file| require file}


module CBF

  class InvalidFormat < StandardError; end

  class StringParameter
    def initialize(default_value)
      @default_value = default_value
    end
    attr_reader :default_value
  end

  FORMAT_CONVERTER_MAP = {
      :heat => Converters::Heat,
      :cloud_formation => Converters::Heat,
      :aeolus => Converters::AeolusV0,
      :aeolus_v0 => Converters::AeolusV0,
    }

  def self.formats()
    FORMAT_CONVERTER_MAP.keys
  end

  def self.get_converter(format)
    if FORMAT_CONVERTER_MAP.include? format
      FORMAT_CONVERTER_MAP[format]
    else
      raise InvalidFormat, format
    end
  end

  def self.parse(format, input_data, options={})
    get_converter(format).parse(input_data, options)
  end

  def self.generate(format, template)
    get_converter(format).generate(template)
  end

end