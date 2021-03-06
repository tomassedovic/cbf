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
      :files => [],
    }

    template = CBF.generate(:heat, source)
    template.wont_be_empty

    parsed = JSON.parse(template)
    parsed['Description'].must_equal(source[:description])
    parsed.must_include 'Parameters'
    parsed.must_include 'Resources'
    parsed.must_include 'Outputs'
  end

  it "must specify required properties for instance resources" do
    source = {
      :description => 'sample template',
      :parameters => [],
      :resources => [{
        :name => 'my instance',
        :type => :instance,
        :image => 'test-image-id',
        :hardware_profile => 'test-hwp',
      }],
      :files => [],
    }

    t = JSON.parse(CBF.generate(:heat, source))
    t['Resources'].must_include 'my instance'
    t['Resources']['my instance'].must_include 'Properties'
    properties = t['Resources']['my instance']['Properties']
    properties.must_include 'ImageId'
    properties['ImageId'].must_equal 'test-image-id'
    properties.must_include 'InstanceType'
    properties['InstanceType'].must_equal 'test-hwp'
  end

  it "must generate KeyName for instances when specified" do
    source = {
      :description => 'sample template',
      :parameters => [],
      :resources => [{
        :name => 'my instance',
        :type => :instance,
        :image => 'test-image-id',
        :hardware_profile => 'test-hwp',
        :key_name => 'my-key'
      }],
      :files => [],
    }

    t = JSON.parse(CBF.generate(:heat, source))

    properties = t['Resources']['my instance']['Properties']
    properties.must_include 'KeyName'
    properties['KeyName'].must_equal 'my-key'
  end

  it "must ensure all files have filenames" do
    source = {
      :description => 'sample template',
      :parameters => [],
      :resources => [{
        :name => 'my instance',
        :type => :instance,
        :image => 'test-image-id',
        :hardware_profile => 'test-hwp',
        :key_name => 'my-key'
      }],
      :files => [
        {
          :executable => true,
          :resource => 'my instance',
          :location => '/tmp/files',
          :mode => '000755',
          :environment => [],
        },
        {
          :name => 'setup.mysql',
          :executable => false,
          :resource => 'my instance',
          :location => '/tmp/files',
          :mode => '000755',
          :environment => [],
        },
      ],
    }

    t = JSON.parse(CBF.generate(:heat, source))
    inst = t['Resources']['my instance']

    # When we specify an executable file, UserData must be present
    inst['Properties'].must_include 'UserData'

    files = inst['Metadata']['AWS::CloudFormation::Init']['config']['files']
    files.must_include '/tmp/files/my-instance-file'
    files.must_include '/tmp/files/setup.mysql'
  end
end