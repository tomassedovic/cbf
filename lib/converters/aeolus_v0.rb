require 'nokogiri'

module CBF
  module Converters

    class AeolusV0

      class InvalidParameterType < StandardError; end

      def self.parse(input_data, options)
        validate!(input_data)
        doc = Nokogiri::XML(input_data) do |config|
          config.strict.nonet
        end
        {
          :name => doc.root.attr('name'),
          :description => (doc % 'description').text,
          :resources => (doc / 'assemblies/assembly').map { |a| parse_assembly(a)},
        }
      end

      def self.validate!(input_data)
        # TODO: add the validation here, raise exceptions on invalid input
      end

      private

      def self.parse_assembly(assembly)
        {
          :name => assembly.attr('name'),
          :type => :instance,
          :hardware_profile => StringParameter.new('hardware_profile', assembly.attr('hwp')),
          :image => StringParameter.new('image', (assembly % 'image').attr('id')),
          :keyname => StringParameter.new('keyname', nil),
          :services => (assembly / 'services/service').map { |s| parse_service(s) },
          :returns => (assembly / 'returns/return').map { |r| parse_return(r) } ,
        }
      end

      def self.parse_service(service)
        result = {
          :name => service.attr('name'),
          :files => (service / 'files/file').map { |f| parse_file(f) },
          :parameters => (service / 'parameters/parameter').map { |p| parse_parameter(p) },
        }
        executable = (service % 'executable')
        result[:executable] = parse_file(executable) if executable

        result
      end

      def self.parse_file(file)
        url = file.attr('url')
        if url
          FileURL.new(url)
        else
          contents = file % 'contents'
          FileContents.new(contents.attr('name'), contents.text)
        end
      end

      def self.parse_parameter(parameter)
        name = parameter.attr('name')
        reference = parameter % 'reference'
        if reference
          ReferenceParameter.new(name, reference.attr('assembly'),
            reference.attr('parameter'))
        else
          value_element = parameter % 'value'
          if value_element
            type = value_element.attr('type') || 'scalar'
            case type
            when 'scalar'
              StringParameter.new(name, value_element.text)
            when 'password'
              PasswordParameter.new(name, value_element.text)
            else
              raise InvalidParameterType, type
            end
          else
            StringParameter.new(name, nil)
          end
        end
      end

      def self.parse_return(return_element)
        return_element.attr('name')
      end

    end
  end
end