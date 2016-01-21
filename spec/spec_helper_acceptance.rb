## TODO : Once deployment using Docker, uncomment, integrate and build acceptance tests with beaker using docker hypervisor.
## until in place, just use rspec tests.

# consul/spec/spec_helper_acceptance.rb
require 'beaker-rspec'

# Not needed as install script takes care of this
redbox_script = ['scripts/install.sh']
hosts.each do |host|
  scp_to host, File.expand_path(File.join(File.dirname(__FILE__), '..', redbox_script)), "/tmp/install.sh"
  on host, "chmod +x /tmp/install.sh"
  on host, "bash -l -c /tmp/install.sh"
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
#    hosts.each do |host|
#      on host, shell('/bin/bash --login')
#    end
  end
end