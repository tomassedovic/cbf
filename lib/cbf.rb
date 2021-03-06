# Copyright 2012 Red Hat, Inc.
# Licensed under the Apache License, Version 2.0, see README for details.

require "cbf/version"
require 'parsers/aeolus_v1'
require 'generators/heat'


module CBF

  def self.convert(template, format, options={})
    template = parse(format, template, options)
    Convertor.new(template)
  end

  PARSERS = {
      :aeolus => Parsers::AeolusV1,
      :aeolus_v1 => Parsers::AeolusV1,
    }

  GENERATORS = {
      :heat => Generators::Heat,
      :cloud_formation => Generators::Heat,
  }

  def self.parsers()
    PARSERS.keys
  end

  def self.generators()
    GENERATORS.keys
  end

  def self.get_parser(format)
    if PARSERS.include? format
      PARSERS[format]
    else
      raise UnknownFormatError, format
    end
  end

  def self.get_generator(format)
    if GENERATORS.include? format
      GENERATORS[format]
    else
      raise UnknownFormatError, format
    end
  end

  def self.parse(format, input_data, options={})
    get_parser(format).parse(input_data, options)
  end

  def self.generate(format, template)
    get_generator(format).generate(template)
  end


  class UnknownFormatError < StandardError; end
  class SyntaxError < StandardError; end
  class ValidationError < StandardError; end


  class Convertor
    attr_reader :template

    def initialize(template)
      @template = template
    end

    def to(format)
      CBF.generate(format, @template)
    end
  end

end