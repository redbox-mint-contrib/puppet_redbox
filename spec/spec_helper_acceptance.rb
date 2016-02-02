require 'beaker-rspec'

redbox_script = ['scripts/install.sh']
hosts.each do |host|
  scp_to host, File.expand_path(File.join(File.dirname(__FILE__), '..', redbox_script)), "/tmp/install.sh"
  on host, "chmod +x /tmp/install.sh"
  if ENV['PUPPET_REDBOX_SCRIPT_ARGS']
    on host, "bash -l -c /tmp/install.sh " +  ENV['PUPPET_REDBOX_SCRIPT_ARGS']
  else
    on host, "bash -l -c /tmp/install.sh"
  end
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      on host, "echo $LOGNAME"
    end
  end
end