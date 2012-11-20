require 'json'

module CBF
  module Converters

    class Heat
      def self.generate(template)
        resources = template['resources'].map { |r| generate_resource(r)}
        JSON.pretty_generate({
          'AWSTemplateFormatVersion' => '2010-09-09',
          'Description' => template['description'],
          'Parameters' => {},
          'Resources' => Hash[*resources.flatten],
          'Outputs' => {},
        })
      end

      private

      def self.generate_resource(resource)
        resource_body = {
          'Type' => RESOURE_TYPE_MAP[resource['type']],
          'Metadata' => { "AWS::CloudFormation::Init" => {} },
          'Properties' => {
            'ImageId' => { "Ref" => "TODO Image" },
            'InstanceType' => { "Ref" => "TODO HardwareProfile" },
            'KeyName' => { "Ref" =>  "TODO KeyName" },
            'UserData' => '',
          },
        }
        [resource['name'], resource_body]
      end

      RESOURE_TYPE_MAP = {
        :instance => 'AWS::EC2::Instance'
      }

    end

  end
end