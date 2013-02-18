# Copyright 2012 Red Hat, Inc.
# Licensed under the Apache License, Version 2.0, see README for details.

require 'spec_helper'
require 'cbf'

describe 'Heat generator' do
  it "must produce a minimal Heat template" do
    source = {
      :description => 'sample template',
      :parameters => [],
      :resources => [],
    }

    template = CBF.generate(:heat, source)
    template.wont_be_empty

    parsed = JSON.parse(template)
    parsed['Description'].must_equal(source[:description])
    parsed.must_include 'Parameters'
    parsed.must_include 'Resources'
    parsed.must_include 'Outputs'
  end
end