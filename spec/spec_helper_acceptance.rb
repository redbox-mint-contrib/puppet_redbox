require 'beaker-rspec'

redbox_script = ['scripts/install.sh']
hosts.each do |host|
  scp_to host, File.expand_path(File.join(File.dirname(__FILE__), '..', redbox_script)), "/tmp/install.sh"
  on host, "chmod +x /tmp/install.sh"
  on host, "bash -l -c /tmp/install.sh ENV['HARVESTER_ARGS']"
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
  end
end