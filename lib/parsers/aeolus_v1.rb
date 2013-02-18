# Copyright 2012 Red Hat, Inc.
# Licensed under the Apache License, Version 2.0, see README for details.

require 'nokogiri'

module CBF
  module Parsers
    class AeolusV1
      class << self

        def parse(input_data, options)
          begin
            doc = Nokogiri::XML(input_data) { |config| config.strict.nonet }
          rescue Nokogiri::XML::SyntaxError
            raise SyntaxError
          end
          validate!(doc)

          assemblies = (doc / 'assemblies/assembly').map { |a| parse_assembly(a, options)}
          assembly_params = (doc / 'assemblies/assembly').map { |a| parse_assembly_parameters(a, options) }.flatten
          resource_params = (doc / 'parameters/parameter').map { |el| parse_parameter(el) }
          {
            :name => doc.root.attr('name'),
            :description => (doc % 'description').text,
            :resources => assemblies,
            :services => (doc / 'services/service').map { |el| parse_service(el) },
            :parameters => assembly_params + resource_params,
            :files => (doc / '//executable|//files/file').map { |el| parse_file(el, resource_params) },
            :outputs => (doc / 'assembly//return').map { |el| parse_return(el) },
          }
        end

        private

        def validate!(doc)
          schema_path = File.join(File.dirname(__FILE__), 'aeolus_v1.rng.xml')
          schema = Nokogiri::XML::RelaxNG(open(schema_path))
          errors = schema.validate(doc) || []
          raise ValidationError unless errors.empty?
        end

        def parse_assembly(assembly, opts)
          name = assembly['name']
          result = {
            :name => name,
            :type => :instance,
            :hardware_profile => {:parameter => 'hardware_profile'},
            :image => {:parameter => 'image'},
          }
          if opts[:require_instance_keys]
            result[:key_name] = {:parameter => 'key_name'}
          end
          return result
        end

        def parse_assembly_parameters(assembly, opts)
          params = [
            assembly_parameter('image', assembly['name'], (assembly % 'image')['id']),
            assembly_parameter('hardware_profile', assembly['name'], assembly['hwp']),
          ]
          if opts[:require_instance_keys]
            params << assembly_parameter('key_name', assembly['name'], nil)
          end
          return params
        end

        def assembly_parameter(name, assembly_name, default_value)
          result = {
            :type => :string,
            :name => name,
            :service => nil,
            :resource => assembly_name,

          }
          result[:default] = default_value if default_value

          result
        end

        def parse_service(service)
          {
            :name => service['name'],
            :resource => service.ancestors('assembly').first['name'],
          }
        end

        def parse_file(file, parameters)
          assembly_name = file.ancestors('assembly').first['name']
          service_name = file.ancestors('service').first['name']

          result = {
            :resource => assembly_name,
            :service => service_name,
            :location => File.join('/var/audrey/tooling/', service_name),
            :owner => nil,
            :group => nil,
            :mode => '000644',
            :executable => false,
          }

          url = file['url']
          if url
            result[:url] = url
            result[:name] = File.basename(URI.parse(url).path)
          else
            contents = file % 'contents'
            result[:name] = contents['name']
            result[:contents] = contents.text
          end

          if file.name == 'executable'
            result[:mode] = '000755'
            result[:executable] = true
            env_params = parameters.select do |p|
              p[:resource] == assembly_name && p[:service] == service_name
            end
            result[:environment] = env_params.map do |p|
              {
                :name => "AUDREY_VAR_#{service_name}_#{p[:name]}",
                :value => {:parameter =>  p[:name]},
              }
            end
          end

          result
        end

        def parse_parameter(parameter)
          assembly_name = parameter.ancestors('assembly').first['name']
          service_name = parameter.ancestors('service').first['name']
          name = parameter['name']

          result = {
            :type => :string,
            :name => name,
            :service => service_name,
            :resource => assembly_name,
            :sensitive => false,
          }

          reference_el = parameter % 'reference'
          if reference_el
            result[:type] = :reference
            result[:referenced_output] = {
              :name => reference_el['parameter'],
              :resource => reference_el['assembly'],
            }
            return result
          end

          value_el = parameter % 'value'
          return result unless value_el

          case value_el['type']
          when 'scalar', nil, ''
            result[:type] = :string
          when 'password'
            result[:type] = :string
            result[:sensitive] = true
          end
          result[:default] = value_el.text

          result
        end

        def parse_return(el)
          {
            :type => :facter,
            :resource => el.ancestors('assembly').first['name'],
            :name => el['name'],
          }
        end

      end
    end
  end
end