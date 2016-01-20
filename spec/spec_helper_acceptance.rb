## TODO : Once deployment using Docker, uncomment, integrate and build acceptance tests with beaker using docker hypervisor.
## until in place, just use rspec tests.

# consul/spec/spec_helper_acceptance.rb
require 'beaker-rspec'

# Not needed as install script takes care of this
redbox_script = ['scripts/install.sh']
hosts.each do |host|
  scp_to host, File.expand_path(File.join(File.dirname(__FILE__), '..', redbox_script)), "/tmp/install.sh"
  on host, "chmod +x /tmp/install.sh"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    #    puppet_module_install(:source => proj_root, :module_name => 'puppet_redbox', :target_module_path => '/usr/share/puppet/modules')
    #    hosts.each do |host|
    #      # Needed for the consul module to download the binary per the modulefile
    #      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    #      on host, puppet('module', 'install', 'puppetlabs/vcsrepo'), { :acceptable_exit_codes => [0,1] }
    #    end
  end
end