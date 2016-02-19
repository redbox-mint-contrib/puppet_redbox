require 'spec_helper_acceptance'

describe 'puppet_redbox pre-install environment' do
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
      ['redbox','mint'].each do |system|
        shell("test -d /opt/#{system}/#{subdirectory}")
      end
    end
  end
  it 'shows redbox and mint links' do
    ['storage', 'solr', 'home/activemq-data', 'home/database'].each do |link|
      ['redbox','mint'].each do |system|
        shell("test -h /opt/#{system}/#{link}")
      end
    end
  end
  it 'shows redbox and mint log links' do
    ['home/logs'].each do |link|
      ['redbox','mint'].each do |system|
        shell("ls -l /opt/#{system}/#{link} && test -h /opt/#{system}/#{link}")
      end
    end
  end
  it 'shows redbox and mint services' do
    case fact('osfamily')
    when 'RedHat'
      case fact('operatingsystemmajrelease')
      when '7'
        service_command = "systemctl status #{system}"
      else
        service_command = "service #{system} status"
      end
    end
    ['redbox','mint'].each do |system|
      shell_result = shell("service #{system} status")
      expect(shell_result.exit_code).to eq 0
      expect(shell_result.stdout).to match /is running/
    end
  end
end