require 'spec_helper_acceptance'

describe 'puppet_redbox pre-install environment' do
  #  it 'should install redbox with no errors' do
  #    shell_result = shell("cd /usr/share/puppet/modules/puppet_redbox/scripts && install.sh")
  #    expect(shell_result.exit_code).to eq 0
  #    expect(shell_result.stdout).not_to match /Fail/
  #    expect(shell_result.stdout).not_to match /err/
  #  end
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

describe 'puppet_redbox basic install' do
  it 'should install ruby, puppet and puppet_rebox without errors' do
    shell_result = shell("bash -l -c '/tmp/install.sh'")
    expect(shell_result.exit_code).to eq 0
  end
  it 'should show ruby version' do
    shell_result = shell("ruby --version")
    expect(shell_result.exit_code).to eq 0
    expect(shell_result.stdout).to match /ruby/
  end
  it 'should show gem version' do
      shell_result = shell("gem --version")
      expect(shell_result.exit_code).to eq 0
      expect(shell_result.stdout).to match /gem/
    end
  #  it 'should show default environment is production' do
  #    shell_result = shell("puppet config print environment")
  #    expect(shell_result.exit_code).to eq 0
  #    expect(shell_result.stdout).to match /production/
  #  end
end