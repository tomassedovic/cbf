require 'nokogiri'

module CBF
  module Parsers

    class AeolusV0

      class InvalidParameterType < StandardError; end

      def self.parse(input_data, options)
        begin
          doc = Nokogiri::XML(input_data) { |config| config.strict.nonet }
        rescue Nokogiri::XML::SyntaxError
          raise SyntaxError
        end
        validate!(doc)
        {
          :name => doc.root.attr('name'),
          :description => (doc % 'description').text,
          :resources => (doc / 'assemblies/assembly').map { |a| parse_assembly(a)},
        }
      end

      def self.validate!(doc)
        schema_path = File.join(File.dirname(__FILE__), 'aeolus_v0.rng.xml')
        schema = Nokogiri::XML::RelaxNG(open(schema_path))
        errors = schema.validate(doc) || []
        raise ValidationError unless errors.empty?
      end

      private

      def self.parse_assembly(assembly)
        {
          :name => assembly.attr('name'),
          :type => :instance,
          :hardware_profile => StringParameter.new('hardware_profile', '', assembly.attr('hwp')),
          :image => StringParameter.new('image', '', (assembly % 'image').attr('id')),
          :keyname => StringParameter.new('keyname', '', nil),
          :services => (assembly / 'services/service').map { |s| parse_service(s) },
          :returns => (assembly / 'returns/return').map { |r| parse_return(r) } ,
        }
      end

      def self.parse_service(service)
        service_name = service.attr('name')
        parameters = (service / 'parameters/parameter').map { |p| parse_parameter(service_name, p) }
        result = {
          :name => service_name,
          :files => (service / 'files/file').map { |f| parse_file(f, service_name) },
          :parameters => parameters,
        }
        executable = (service % 'executable')
        if executable
          file = parse_file(executable, service_name)
          parameters.each do |param|
            file.environment << {
              :name => "AUDREY_VAR_#{service_name}_#{param.name}",
              :value => param,
            }
          end
          result[:executable] = file
        end

        result
      end

      def self.parse_file(file, service_name)
        url = file.attr('url')
        location = File.join('/var/audrey/tooling/', service_name)
        if url
          FileURL.new(url, location)
        else
          contents = file % 'contents'
          FileContents.new(contents.attr('name'), contents.text, location)
        end
      end

      def self.parse_parameter(service_name, parameter)
        name = parameter.attr('name')
        reference = parameter % 'reference'
        if reference
          ReferenceParameter.new(name, service_name, reference.attr('assembly'),
            reference.attr('parameter'))
        else
          value_element = parameter % 'value'
          if value_element
            type = value_element.attr('type') || 'scalar'
            case type
            when 'scalar'
              StringParameter.new(name, service_name, value_element.text)
            when 'password'
              PasswordParameter.new(name, service_name, value_element.text)
            else
              raise InvalidParameterType, type
            end
          else
            StringParameter.new(name, service_name, nil)
          end
        end
      end

      def self.parse_return(return_element)
        return_element.attr('name')
      end

    end
  end
end