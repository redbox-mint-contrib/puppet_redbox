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
      should have_resource_count(6)

      # file should 1. ensure destination 2. link back to original
      should have_exec_resource_count(3)
      should have_file_resource_count(2)
    end

    it do
      should contain_file('/mnt/data/redbox/storage').with({
        :ensure => 'directory',
        :owner => 'redbox'
      }).that_comes_before('Exec[cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/]')

      should contain_exec('cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/').with({
        :unless => 'test -h /opt/redbox/storage'
      }).that_comes_before('Exec[rm -Rf /opt/redbox/storage]')
      .that_requires('File[/mnt/data/redbox/storage]')

      should contain_exec('rm -Rf /opt/redbox/storage').with({
        :unless => 'test -h /opt/redbox/storage'
      }).that_comes_before('Exec[ln -sf /mnt/data/redbox/storage /opt/redbox/storage]')
      .that_requires('Exec[cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/]')

      should contain_exec('ln -sf /mnt/data/redbox/storage /opt/redbox/storage').with({
        :unless => 'test -h /opt/redbox/storage'
      }).that_comes_before('File[/opt/redbox/storage]')
      .that_requires('Exec[rm -Rf /opt/redbox/storage]')

      should contain_file('/opt/redbox/storage').with({
        :ensure => 'link',
        :owner => 'redbox',
        :force => 'true',
        :target => '/mnt/data/redbox/storage'}).that_requires('Exec[ln -sf /mnt/data/redbox/storage /opt/redbox/storage]')

    end
  end
end