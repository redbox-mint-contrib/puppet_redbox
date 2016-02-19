require 'spec_helper_acceptance'

describe 'ruby_puppet basic install' do
  it 'should show ruby version' do
    result = on(agents.first, "ruby --version")
    expect(result.exit_code).to eq 0
    expect(result.stdout).to match /ruby/
  end
  it 'should show gem version' do
    result = on(agents.first, "gem --version")
    expect(result.exit_code).to eq 0
  end
  it 'should show default environment is production' do
    result = on(agents.first, "puppet config print environment")
    expect(result.exit_code).to eq 0
    expect(result.stdout).to match /production/
  end
end

describe 'puppet_redbox basic install' do
  it 'shows redbox installation' do
    result = on(agents.first, "test -d /opt/redbox")
    expect(result.exit_code).to eq 0
  end
  it 'shows mint installation' do
    result = on(agents.first, "test -d /opt/mint")
    expect(result.exit_code).to eq 0
  end
  it 'lists redbox and mint subdirectories' do
    ['home', 'portal', 'server', 'solr', 'storage'].each do |subdirectory|
      ['redbox','mint'].each do |system|
        result = on(agents.first, "test -d /opt/#{system}/#{subdirectory}")
        expect(result.exit_code).to eq 0
      end
    end
  end
  it 'shows redbox and mint links' do
    ['storage', 'solr', 'home/activemq-data', 'home/database'].each do |link|
      ['redbox','mint'].each do |system|
        result = on(agents.first, "test -h /opt/#{system}/#{link}")
        expect(result.exit_code).to eq 0
      end
    end
  end
  it 'shows redbox and mint log links' do
    ['home/logs'].each do |link|
      ['redbox','mint'].each do |system|
        result = on(agents.first, "ls -l /opt/#{system}/#{link} && test -h /opt/#{system}/#{link}")
        expect(result.exit_code).to eq 0
      end
    end
  end
  it 'shows redbox and mint services' do
    ['redbox','mint'].each do |system|
#      case fact('osfamily')
#      when 'RedHat'
#        case fact('operatingsystemmajrelease')
#        when '7'
#          service_command = "systemctl status #{system}"
#        else
          service_command = "service #{system} status"
#        end
#      end
      result = on(agents.first, service_command)
      expect(result.exit_code).to eq 0
      expect(result.stdout).to match /is running/
    end
  end
end