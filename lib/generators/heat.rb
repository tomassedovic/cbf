require 'json'

module CBF
  module Generators

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
          resource[:services].each do |service|
            service[:parameters].each do |p|
              case p
              when StringParameter, PasswordParameter
                param_key = [service[:name], p.name].join('_')
                params << [resource[:name], param_key, p]
              end
            end
          end
        end
        params.map { |p| generate_parameter_declaration(*p) }
      end

      def self.generate_parameter_declaration(resource_name, param_name, param)
        definition = {}

        definition['Default'] = param.default_value if param.default_value

        case param
        when StringParameter
          definition['Type'] = 'String'
        end
        [resource_param_name(resource_name, param_name), definition]
      end

      def self.generate_resource(resource)
        name = resource[:name]
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


        files = resource[:services].map { |s| s[:files] }.flatten
        executables = resource[:services].map { |s| s[:executable] }.compact
        generated_files = (files + executables).map { |f| generate_file(f) }

        unless files.empty?
          cfn_init = resource_body['Metadata']['AWS::CloudFormation::Init']
          cfn_init['config'] ||= {}
          cfn_init['config']['files'] = Hash[*generated_files.flatten]
        end

        unless executables.empty?
          user_data = ['!#/bin/bash'] + executables.map { |f| File.join(f.location, f.name) }
          resource_body['Properties']['UserData'] = user_data.join("\n")
        end

        [name, resource_body]
      end

      def self.generate_file(file)
        body = {
          'owner' => file.owner,
          'group' => file.group,
          'mode' => file.mode,
        }

        case file
        when FileURL
          body['source'] = file.url
        when FileContents
          body['content'] = file.contents
          body['encoding'] = 'plain'
        end

        [File.join(file.location, file.name), body]
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