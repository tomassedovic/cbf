require 'nokogiri'

module Aeolus
  module Convert
    module Converters

      class StringParameter
        def initialize(*attrs)
        end
      end

      class Aeolus_V0

        def self.parse(input_data, options)
          # TODO: validate the XML
          doc = Nokogiri::XML(input_data)
          {
            'name' => doc.root.attr('name'),
            'description' => (doc % 'description').text,
            'assemblies' => (doc / 'assemblies/assembly').map { |a| parse_assembly(a)},
          }
        end

        private

        def self.parse_assembly(assembly)
          {
            'name' => assembly.attr('name'),
            'hardware_profile' => StringParameter.new(assembly.attr('hwp')),
            'image' => StringParameter.new((assembly % 'image').attr('id')),
            'services' => (assembly / 'services/service').map { |s| parse_service(s) },
            'returns' => ['TODO'],
          }
        end

        def self.parse_service(service)
          {
            'name' => service.attr('name'),
            'executable_url' => (service % 'executable').attr('url'),
            'parameters' => (service / 'parameters/parameter').map { |p| parse_parameter(p) },
          }
        end

        def self.parse_parameter(parameter)
          # TODO: check for references
          result = {
            'name' => parameter.attr('name'),
          }
          value = (parameter % 'value')
          if value
            result['type'] = value.attr('type')
            result['value'] = value.content
          end
          result
        end

      end

    end
  end
end