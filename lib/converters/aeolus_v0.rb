require 'nokogiri'

module CBF
  module Converters

    class AeolusV0
      def self.parse(input_data, options)
        # TODO: validate the XML
        doc = Nokogiri::XML(input_data)
        {
          :name => doc.root.attr('name'),
          :description => (doc % 'description').text,
          :resources => (doc / 'assemblies/assembly').map { |a| parse_assembly(a)},
        }
      end

      private

      def self.parse_assembly(assembly)
        {
          :name => assembly.attr('name'),
          :type => :instance,
          :hardware_profile => StringParameter.new(assembly.attr('hwp')),
          :image => StringParameter.new((assembly % 'image').attr('id')),
          :keyname => StringParameter.new(''),
          :services => (assembly / 'services/service').map { |s| parse_service(s) },
          :returns => ['TODO'],
        }
      end

      def self.parse_service(service)
        {
          :name => service.attr('name'),
          :executable_url => (service % 'executable').attr('url'),
          :parameters => (service / 'parameters/parameter').map { |p| parse_parameter(p) },
        }
      end

      def self.parse_parameter(parameter)
        # TODO: check for references
        result = {
          :name => parameter.attr('name'),
        }
        value = (parameter % 'value')
        if value
          result[:type] = value.attr('type')
          result[:value] = value.content
        end
        result
      end

    end

  end
end