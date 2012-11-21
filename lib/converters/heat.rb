require 'json'

module CBF
  module Converters

    class Heat
      def self.generate(template)
        parameters = self.generate_params(template)
        resources = template[:resources].map { |r| generate_resource(r)}
        JSON.pretty_generate({
          'AWSTemplateFormatVersion' => '2010-09-09',
          'Description' => template[:description],
          'Parameters' => Hash[*parameters.flatten],
          'Resources' => Hash[*resources.flatten],
          'Outputs' => {},
        })
      end

      private

      def self.generate_params(template)
        params = []
        template[:resources].each do |resource|
          resource.each do |key, value|
            case value
            when StringParameter
              params << [resource[:name], key, value]
            end
          end
        end
        params.map { |p| generate_parameter_declaration(*p) }
      end

      def self.generate_parameter_declaration(resource_name, param_name, param)
        definition = {}

        unless param.default_value.empty?
          definition['Default'] = param.default_value
        end

        case param
        when StringParameter
          definition['Type'] = 'String'
        end
        [resource_param_name(resource_name, param_name), definition]
      end

      def self.generate_resource(resource)
        name = resource['name']
        resource_body = {
          'Type' => RESOURE_TYPE_MAP[resource[:type]],
          'Metadata' => { "AWS::CloudFormation::Init" => {} },
          'Properties' => {
            'ImageId' => reference_link(resource, :image),
            'InstanceType' => reference_link(resource, :hardware_profile),
            'KeyName' => reference_link(resource, :keyname),
            'UserData' => '',
          },
        }
        [name, resource_body]
      end

      def self.reference_link(resource, type)
        value = resource[type]
        name = resource[:name]
        case value
        when String
          value
        when StringParameter
          { 'Ref' => resource_param_name(name, type) }
        end
      end

      def self.resource_param_name(name, type)
        "#{name}_#{type}"
      end

      RESOURE_TYPE_MAP = {
        :instance => 'AWS::EC2::Instance'
      }

    end

  end
end