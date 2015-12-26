require 'spec_helper'

describe 'puppet_redbox::institutional_build::overlay' do
  shared_context "stubbed params" do
    let (:stubbed_title) {'https://github.com/redbox-mint-contrib/rb-sample-1.8-institutional-build'}
    let(:stubbed_local_repo) {'/tmp/rb-sample-1.8-institutional-build'}
    let(:stubbed_install_dir) {'/opt/redbox'}
    let(:title) { stubbed_title }
  end

  let :default_params do
    {
      :system_install_directory => '/opt/redbox',
    }
  end

  context "Given default parameters" do
    include_context "stubbed params"
    let :params do
      default_params
    end

    it { should compile.with_all_deps }

    it { should have_resource_count(3) }

    it { should have_puppet_redbox__institutional_build__overlay_resource_count(1) }

    it { should have_vcsrepo_resource_count(1) }

    it { should have_exec_resource_count(1) }

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
      should contain_exec("copy files from #{stubbed_local_repo} to #{stubbed_install_dir}").with({
        :command => "/usr/bin/rsync -rcvzh --filter='- .git*' --filter='- README*' #{stubbed_local_repo}/* #{stubbed_install_dir}/",
      }).that_requires("Vcsrepo[clone #{stubbed_title} to #{stubbed_local_repo}]")
    end
  end

  context "Given non-absolute path for 'local_repo_parent'" do
    include_context "stubbed params"
    let :params do
      default_params.merge({
        :local_repo_parent => 'tmp'
      })
    end

    it do
      should raise_error(Puppet::Error, /not an absolute path/)
    end

  end

  context "Given undef for 'system_install_directory'" do
    include_context "stubbed params"
    let :params do
      default_params.merge({
        :system_install_directory => :undef
      })
    end

    it do
      should raise_error(Puppet::Error, /must specify a system install directory/)
    end

  end

  context "Given revision is not master" do
    include_context "stubbed params"
    let :params do
      default_params.merge({
        :revision => '0123',
      })
    end

    it do
      should contain_vcsrepo("clone #{stubbed_title} to #{stubbed_local_repo}").with({
        :ensure   => 'present'
      })
    end

  end
end