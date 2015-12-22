require 'spec_helper'

describe 'puppet_redbox::institutional_build::overlay' do
  let :default_params do
    {
      :ssh_user                 => 'root',
      :revision                 => 'master',
      :system_install_directory => '/opt/redbox',
      :local_repo_parent        => '/tmp'
    }
  end

  context "With default parameters" do
    let(:stubbed_title) {'https://github.com/redbox-mint-contrib/rb-sample-1.8-institutional-build'}
    let(:stubbed_local_repo) {'/tmp/rb-sample-1.8-institutional-build'}
    let(:stubbed_install_dir) {'/opt/redbox'}
    let(:title) { stubbed_title }
    let :params do
      default_params
    end

    it do
      should contain_vcsrepo("clone #{stubbed_title} to #{stubbed_local_repo}").with({
        :provider => 'git',
        :source  => "#{stubbed_title}",
        :path => "#{stubbed_local_repo}",
        :revision => 'master',
        :user  => 'root',
        :ensure   => 'latest'
      })
    end

    it do
      should contain_exec("copy vcsrepo files from #{stubbed_local_repo} to #{stubbed_install_dir}").with({
        :command => "/usr/bin/rsync -rcvzh --filter='- .git*' --filter='- README*' #{stubbed_local_repo}/* #{stubbed_install_dir}/",
      })
    end
  end
end