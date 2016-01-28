require 'spec_helper'

describe 'puppet_redbox::move_and_link_all' do
  let!(:create_parent_directories) { MockFunction.new('create_parent_directories', {:type => :statement})}
  shared_context "stubbed params" do
    let :title do {
        'system' => 'redbox',
        'package' => 'redbox-distro',
        'server_url_context' => 'redbox',
        'install_directory' => '/opt/redbox',
      }
    end
  end
  let :default_params do
    {
      :packages => title,
      :target_parent => '/opt',
      :owner => 'redbox',
      :relocation_data_dir => '/mnt/data',
      :relocation_logs_dir => '/mnt/logs',
      :exec_path => [
      '/usr/local/bin',
      '/opt/local/bin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin']
    }
  end
  context "Given default parameters" do
    include_context "stubbed params"
    let :params do
      default_params
    end
    it {should compile.with_all_deps}
    it {
      should contain_exec('stop redbox before tidy/move/link').with({:command => 'service redbox stop'})
      should contain_puppet_redbox__add_tidy('redbox').that_requires('Exec[stop redbox before tidy/move/link]')
      should contain_file('/mnt/data/redbox').with({:owner => 'redbox', :recurse => 'true'})
      should contain_file('/mnt/data/redbox/home').with({:owner => 'redbox', :recurse => 'true'}).that_requires('File[/mnt/data/redbox]')
      should contain_puppet_redbox__move_and_link_directory('redbox/solr')
        .with({:target_parent => '/opt', :relocation => '/mnt/data', :owner => 'redbox'})
        .that_requires('Exec[stop redbox before tidy/move/link]')
        .that_requires('File[/mnt/data/redbox]')
        .that_requires('File[/mnt/data/redbox/home]')
        .that_comes_before('Exec[restart redbox after tidy/move/link]')
      should contain_puppet_redbox__move_and_link_directory('redbox/storage')
        .with({:target_parent => '/opt', :relocation => '/mnt/data', :owner => 'redbox'})
        .that_requires('Exec[stop redbox before tidy/move/link]')
        .that_requires('File[/mnt/data/redbox]')
        .that_requires('File[/mnt/data/redbox/home]')
        .that_comes_before('Exec[restart redbox after tidy/move/link]')
      should contain_puppet_redbox__move_and_link_directory('redbox/home/database')
        .with({:target_parent => '/opt', :relocation => '/mnt/data', :owner => 'redbox'})
        .that_requires('Exec[stop redbox before tidy/move/link]')
        .that_requires('File[/mnt/data/redbox]')
        .that_requires('File[/mnt/data/redbox/home]')
        .that_comes_before('Exec[restart redbox after tidy/move/link]')
      should contain_puppet_redbox__move_and_link_directory('redbox/home/activemq-data')
        .with({:target_parent => '/opt', :relocation => '/mnt/data', :owner => 'redbox'})
        .that_requires('Exec[stop redbox before tidy/move/link]')
        .that_requires('File[/mnt/data/redbox]')
        .that_requires('File[/mnt/data/redbox/home]')
        .that_comes_before('Exec[restart redbox after tidy/move/link]')
      should contain_puppet_redbox__move_and_link_directory('/opt/redbox/home/logs')
        .with({:relocation => '/mnt/logs/redbox', :owner => 'redbox'})
        .that_requires('Exec[stop redbox before tidy/move/link]')
        .that_requires('Puppet_redbox::Add_tidy[redbox]')
        .that_comes_before('Exec[restart redbox after tidy/move/link]')
      should contain_exec('restart redbox after tidy/move/link').with({:command => 'service redbox restart'})
      should contain_file('/var/log/redbox')
        .with({:ensure => 'link', :target => '/mnt/logs/redbox', :owner => 'redbox'})
        .that_requires('Puppet_redbox::Move_and_link_directory[/opt/redbox/home/logs]')
    }
  end
end