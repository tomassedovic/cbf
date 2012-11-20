# Require all ruby files in lib/converters
converter_paths = File.join(File.dirname(__FILE__), 'converters', '*.rb')
Dir.glob(converter_paths).each { |file| require file}


module Aeolus
  module Convert

    class InvalidFormat < StandardError; end

    def self.formats()
      Converters.constants.map { |name| name.downcase.to_sym }
    end

    def self.get_converter(format)
      begin
        name = format.to_s.split('_').map(&:capitalize).join('_')
        Converters.const_get name
      rescue NameError
        raise InvalidFormat.new(format)
      end
    end

    def self.parse(format, input_data, options={})
      get_converter(format).parse(input_data, options)
    end

    def self.generate(format, template)
      get_converter(format).generate(template)
    end

  end
end