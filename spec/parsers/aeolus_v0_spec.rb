require 'spec_helper'
require 'cbf'

describe 'Aeolus v.0 parser' do
  it "must advertise the Aeolus v.0 format" do
    CBF.parsers.must_include :aeolus_v0
  end

  it "must successfully parse the wordpress deployable" do
    deployable_path = "#{SAMPLES_PATH}/aeolus_v0/wordpress.xml"
    CBF.parse(:aeolus_v0, open(deployable_path))
  end

  it "must successfully parse the drupal deployable" do
    deployable_path = "#{SAMPLES_PATH}/aeolus_v0/drupal.xml"
    CBF.parse(:aeolus_v0, open(deployable_path))
  end

  it "must successfully parse the sample deployable" do
    deployable_path = "#{SAMPLES_PATH}/aeolus_v0/sample.xml"
    CBF.parse(:aeolus_v0, open(deployable_path))
  end

  it "must fail for invalid XML" do
    proc do
      CBF.parse(:aeolus_v0, '<deployable')
    end.must_raise Nokogiri::XML::SyntaxError
  end
end