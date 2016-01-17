require 'spec_helper'

describe 'puppet_redbox::move_and_link_directory' do
  let!(:create_parent_directories) { MockFunction.new('create_parent_directories', {:type => :statement})
  }
  shared_context "stubbed params" do
    let (:title) {'redbox/storage'}
  end

  let :default_params do
    {
      :target => title,
      :target_parent => '/opt',
      :relocation => '/mnt/data',
      :owner => 'redbox'
    }
  end

  context "Given default parameters" do
    include_context "stubbed params"
    let :params do
      default_params
    end

    it {should compile.with_all_deps}
    it "has a known and consistent number of resources" do
      should have_resource_count(2)

      # file should 1. ensure destination 2. link back to original
      should have_exec_resource_count(1)
    end

    it do
      should contain_exec("cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/ && rm -Rf /opt/redbox/storage && ln -s /mnt/data/redbox/storage /opt/redbox/storage")
    end
  end
end