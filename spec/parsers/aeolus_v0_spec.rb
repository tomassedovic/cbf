require 'spec_helper'
require 'cbf'

describe 'Aeolus v.0 parser' do
  it "must advertise the Aeolus v.0 format" do
    CBF.parsers.must_include :aeolus_v0
  end

  it "must successfully parse the wordpress deployable" do
    deployable_path = "#{SAMPLES_PATH}/aeolus_v0/wordpress.xml"
    result = CBF.parse(:aeolus_v0, open(deployable_path))
    result[:name].must_equal "Wordpress Multi-Instance Deployable"
    result[:description].must_equal "This is an example of a multi deployment that deploys wordpress across an apache and mysql instance"

    result[:resources].count.must_equal 2
    result[:resources][0][:name].must_equal "webserver"
    result[:resources][1][:name].must_equal "database"

    result[:services].count.must_equal 2
    result[:services][0][:name].must_equal "http"
    result[:services][1][:name].must_equal "mysql"

    http_params = result[:parameters].select do
      |p| p[:resource] == "webserver" && p[:service] == "http"
    end
    http_params.count.must_equal 6

    mysql_params = result[:parameters].select do
      |p| p[:resource] == "database" && p[:service] == "mysql"
    end
    mysql_params.count.must_equal 5

    result[:files].count.must_equal 3
    result[:files].select { |f| f[:executable] }.count.must_equal 2

    result[:outputs].count.must_equal 5
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
    end.must_raise CBF::SyntaxError
  end

  it "must fail for invalid Deployable format" do
    proc do
      CBF.parse(:aeolus_v0, '<deployable></deployable>')
    end.must_raise CBF::ValidationError
  end
end