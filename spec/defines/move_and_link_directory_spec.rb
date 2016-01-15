require 'spec_helper'

describe 'puppet_redbox::link' do
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
      should have_resource_count(5)
      
      # file should 1. ensure destination 2. ensure ownership of destination once moved files 3. link back to original
      should have_file_resource_count(3)
      
      # move files
      should have_exec_resource_count(1)
    end

    it do
      should contain_exec('mv redbox/storage').with({
        :command => 'mv /opt/redbox/storage /mnt/data/redbox/storage'
      }).that_requires('File[/mnt/data]')

      should contain_file('/mnt/data/redbox/storage').with({
        :ensure => 'directory',
        :owner => 'redbox',
        :recurse => true,
      }).that_requires('Exec[mv redbox/storage]')

      should contain_file('/opt/redbox/storage').with({
        :ensure => 'link',
        :target => '/mnt/data/redbox/storage'
      }).that_requires('Exec[mv redbox/storage]')
    end
  end
end