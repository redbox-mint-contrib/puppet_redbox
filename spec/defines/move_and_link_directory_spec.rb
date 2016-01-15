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
      should have_resource_count(3)

      # file should 1. ensure destination 2. link back to original
      should have_file_resource_count(2)
    end

    it do
      should contain_file('/mnt/data/redbox/storage').with({
        :ensure => 'present',
        :recurse => 'true',
        :source => '/opt/redbox/storage',
        :validate_cmd => "test -d /opt/redbox/storage",
        :source_permissions => 'use_when_creating',
      })

      should contain_file('/opt/redbox/storage').with({
        :ensure => 'link',
        :force => 'true',
        :validate_cmd => "test -d /opt/redbox/storage",
        :target => '/mnt/data/redbox/storage'
      }).that_requires('File[/mnt/data/redbox/storage]')
    end
  end
end