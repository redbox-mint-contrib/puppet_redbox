require 'spec_helper'

describe 'puppet_redbox::institutional_build::puppet_overlay' do
  shared_context "stubbed params" do
    let (:stubbed_title) {'puppet:///modules/foobar/rds-genomics'}
    let(:title) { stubbed_title }
  end

  let :default_params do
    {
      :local_staging        => '/tmp/rds-genomics',
    }
  end

  context "Given default parameters" do
    include_context "stubbed params"
    let :params do
      default_params
    end

    it { should compile.with_all_deps }

    it { should have_resource_count(2) }

    it { should have_file_resource_count(1) }

    it do
      should contain_file("/tmp/rds-genomics").with({
        :source => 'puppet:///modules/foobar/rds-genomics',
        :recurse  => true,
      })
    end

  end

end