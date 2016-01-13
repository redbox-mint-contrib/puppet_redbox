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
    it do
      should contain_exec('mv redbox/storage').with({
        :command => 'mv /opt/redbox/storage /mnt/data/redbox/storage'
      }).that_requires('File[/mnt/data]')

      should contain_file('/mnt/data/redbox/storage').with({
        :ensure => 'directory',
        :owner => 'redbox',
        :recurse => true,
      }).that_requires('Exec[mv redbox/storage]')
    end
  end
end