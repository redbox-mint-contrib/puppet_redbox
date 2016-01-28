require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-utils'

if ENV['COVERAGE']
  RSpec.configure do |c|
    test_instance = RSpec::Puppet::Coverage.instance
    c.before(:suite)do
      ## add here any resources to be filtered out from coverage
      ## e.g., test_instance.filters << ['Postgresql::Server::Db[curationmanager]']
      test_instance.filters << []
    end
    c.after(:suite) do
      test_instance.report!
    end
  end
end

