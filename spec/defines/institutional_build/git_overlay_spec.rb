require 'spec_helper'

describe 'puppet_redbox::institutional_build::git_overlay' do
  shared_context "stubbed params" do
    let (:stubbed_title) {'https://github.com/redbox-mint-contrib/rb-sample-1.8-institutional-build'}
    let(:title) { stubbed_title }
  end

  let :default_params do
    {
      :institution_ssh_user => 'root',
      :revision             => 'master',
      :local_staging        => '/tmp/rb-sample-1.8-institutional-build.git',
    }
  end

  context "Given default parameters" do
    include_context "stubbed params"
    let :params do
      default_params
    end

    it { should compile.with_all_deps }

    it { should have_resource_count(2) }

    it { should have_vcsrepo_resource_count(1) }

    it do
      should contain_vcsrepo("clone #{stubbed_title} to /tmp/rb-sample-1.8-institutional-build.git").with({
        :provider => 'git',
        :source  => "#{stubbed_title}",
        :path => "/tmp/rb-sample-1.8-institutional-build.git",
        :revision => 'master',
        :user  => 'root',
        :ensure   => 'latest'
      })
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
      should contain_vcsrepo("clone #{stubbed_title} to /tmp/rb-sample-1.8-institutional-build.git").with({
        :ensure   => 'present'
      })
    end

  end
end