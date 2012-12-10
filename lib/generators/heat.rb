require 'json'

module CBF
  module Generators

    class Heat
      def self.generate(template)
        parameters = self.generate_params(template[:parameters])
        resources = template[:resources].map { |r| generate_resource(template, r)}
        JSON.pretty_generate({
          'AWSTemplateFormatVersion' => '2010-09-09',
          'Description' => template[:description],
          'Parameters' => Hash[*parameters.flatten],
          'Resources' => Hash[*resources.flatten],
          'Outputs' => {},
        })
      end

      private

      def self.generate_params(parameters)
        non_reference_params = parameters.reject { |p| p[:type] == :reference }
        non_reference_params.map do |p|
          definition = {
            'Type' => PARAMETER_TYPE_MAP[p[:type]],
          }
          definition['Default'] = p[:default] if p[:default]
          definition['NoEcho'] = p[:sensitive] if p[:sensitive]

          [parameter_name(p), definition]
        end
      end

      def self.parameter_name(parameter)
        [parameter[:resource], parameter[:service], parameter[:name]].compact.join('_')
      end


      def self.generate_resource(template, resource)
        name = resource[:name]
        resource_body = {
          'Type' => RESOURE_TYPE_MAP[resource[:type]],
          'Metadata' => { "AWS::CloudFormation::Init" => {} },
          'Properties' => {
            'ImageId' => resolve_parameter_ref_or_value(name, resource[:image]),
            'InstanceType' => resolve_parameter_ref_or_value(name, resource[:hardware_profile]),
            'UserData' => '',
          },
        }

        files = template[:files].select { |f| f[:resource] == name }
        generated_files = files.map { |f| generate_file(f) }

        unless files.empty?
          cfn_init = resource_body['Metadata']['AWS::CloudFormation::Init']
          cfn_init['config'] ||= {}
          cfn_init['config']['files'] = Hash[*generated_files.flatten]
        end

        executables = files.select { |f| f[:executable] }
        resource_body['Properties']['UserData'] = generate_user_data(name, executables, template[:parameters])

        [name, resource_body]
      end

      def self.resolve_parameter_ref_or_value(resource_name, value)
        case value
        when String
          value
        when Hash
          name = parameter_name({:name => value[:parameter], :resource => resource_name})
          { "Ref" => name }
        end
      end

      def self.generate_file(file)
        body = {
          'owner' => file[:owner],
          'group' => file[:group],
          'mode' => file[:mode],
        }

        if file[:url]
          body['source'] = file[:url]
        else
          body['content'] = file[:contents]
          body['encoding'] = 'plain'
        end

        [file_abs_path(file), body.reject { |k, v| v.nil? } ]
      end

      def self.file_abs_path(file)
        File.join(file[:location], file[:name])
      end

      def self.generate_user_data(resource_name, executables, params)
        return '' if executables.empty?

        lines = ['!#/bin/bash'] + executables.map do |f|
          export_commands = f[:environment].map do |env|
            param = params.find do |p|
              p[:resource] == resource_name && p[:name] == env[:value][:parameter]
            end

            ref = case param[:type]
            when :string, :password
              { "Ref" => parameter_name(param) }
            when :reference
              output_name = param[:referenced_output][:name]
              attribute_name = OUTPUTS_MAP[output_name] || output_name
              { "Fn::GetAtt" => [param[:referenced_output][:resource], attribute_name] }
            end
            { "Fn::Join" => ["", ["export #{env[:name]}=", ref]]}
          end
          unexport_commands = f[:environment].map { |env| "unset #{env[:name]}" }

          [export_commands, file_abs_path(f), unexport_commands]
        end

        { "Fn::Base64" => { "Fn::Join" => ["\n", lines.flatten] }}
      end


      PARAMETER_TYPE_MAP = {
        :string => 'String',
        :password => 'String',
      }

      RESOURE_TYPE_MAP = {
        :instance => 'AWS::EC2::Instance'
      }

      OUTPUTS_MAP = {
        'ipaddress' => 'PublicIp',
        'hostname' => 'DNSName',
      }

    end

  end
end