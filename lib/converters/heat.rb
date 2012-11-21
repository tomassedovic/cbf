require 'json'

module CBF
  module Converters

    class Heat
      def self.generate(template)
        parameters = self.generate_params(template)
        resources = template['resources'].map { |r| generate_resource(r)}
        JSON.pretty_generate({
          'AWSTemplateFormatVersion' => '2010-09-09',
          'Description' => template['description'],
          'Parameters' => Hash[*parameters.flatten],
          'Resources' => Hash[*resources.flatten],
          'Outputs' => {},
        })
      end

      private

      def self.generate_params(template)
        params = []
        template['resources'].each do |resource|
          resource.each do |key, value|
            case value
            when StringParameter
              params << [resource['name'], key, value]
            end
          end
        end
        params.map { |p| generate_parameter(*p) }
      end

      def self.generate_parameter(resource_name, param_name, param)
        definition = {
          'Default' => param.default_value
        }
        case param
        when StringParameter
          definition['Type'] = 'String'
        end
        pname = param_name.split('_').map(&:capitalize).join('')
        name = "#{resource_name}_#{pname}"
        [name, definition]
      end

      def self.generate_resource(resource)
        name = resource['name']
        resource_body = {
          'Type' => RESOURE_TYPE_MAP[resource['type']],
          'Metadata' => { "AWS::CloudFormation::Init" => {} },
          'Properties' => {
            'ImageId' => image_reference(name, resource['image']),
            'InstanceType' => hwp_reference(name, resource['hardware_profile']),
            'KeyName' => { "Ref" =>  "#{name}_KeyName" },
            'UserData' => '',
          },
        }
        [name, resource_body]
      end

      def self.image_reference(resource_name, image)
        case image
        when String
          image
        when StringParameter
          { 'Ref' => "#{resource_name}_Image" }
        else
          raise 'Unknown Image reference type'
        end
      end

      def self.hwp_reference(resource_name, hardware_profile)
        case hardware_profile
        when String
          hardware_profile
        when StringParameter
          { 'Ref' => "#{resource_name}_HardwareProfile" }
        else
          raise 'Unknown HardwareProfile reference type'
        end
      end

      RESOURE_TYPE_MAP = {
        :instance => 'AWS::EC2::Instance'
      }

    end

  end
end