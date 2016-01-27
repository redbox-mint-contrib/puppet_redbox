require 'spec_helper_acceptance'

describe 'puppet_redbox pre-install environment' do
  it 'should output correct platform details' do
    shell_result = shell("cat /etc/redhat-release")
    expect(shell_result.exit_code).to eq 0
    expect(shell_result.stdout).to match /CentOS.*release 6.7/
  end
  it 'should show puppet_redbox install script' do
    shell_result = shell("ls -l /tmp/install.sh")
    expect(shell_result.exit_code).to eq 0
    expect(shell_result.stdout).to match /install.sh/
  end
end

describe 'ruby_puppet basic install' do
  it 'should show ruby version' do
    shell_result = shell("ruby --version")
    expect(shell_result.exit_code).to eq 0
    expect(shell_result.stdout).to match /ruby/
  end
  it 'should show gem version' do
    shell_result = shell("gem --version")
    expect(shell_result.exit_code).to eq 0
  end
  it 'should show default environment is production' do
    shell_result = shell("puppet config print environment")
    expect(shell_result.exit_code).to eq 0
    expect(shell_result.stdout).to match /production/
  end
end

describe 'puppet_redbox basic install' do
  it 'shows redbox installation' do
    shell_result = shell("test -d /opt/redbox")
    expect(shell_result.exit_code).to eq 0
  end
  it 'shows mint installation' do
    shell_result = shell("test -d /opt/mint")
    expect(shell_result.exit_code).to eq 0
  end
  it 'lists redbox and mint subdirectories' do
    ['home', 'portal', 'server', 'solr', 'storage'].each do |subdirectory|
      shell("test -d /opt/redbox/#{subdirectory}")
      shell("test -d /opt/mint/#{subdirectory}")
    end
  end
  it 'shows redbox and mint links' do
    ['storage', 'solr', 'home/activemq-data', 'home/database'].each do |link|
      ['redbox','mint'].each do |system|
        shell("test -h /opt/#{system}/#{link}") do |result|
          expect(result.exit_code).to eq 0
          expect(result.stdout).to match /mnt\/data\/#{system}/
        end
      end
    end
  end
end