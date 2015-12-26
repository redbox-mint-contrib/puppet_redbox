require 'spec_helper'

describe 'puppet_redbox::pre_upgrade_backup' do
  let :default_params do
    {
      :backup_destination_parent_path => '/tmp',
    }
  end

  context "Given default parameters for standard redbox installation" do
    let(:title) {'/opt/redbox'}
    let :params do
      default_params.merge({:system_name => 'redbox'})
    end

    it {should compile.with_all_deps}

    it "has a known and consistent number of resources" do
      should have_resource_count(5)

      should have_puppet_redbox__pre_upgrade_backup_resource_count(1)

      # file resource ensures backup destination folder
      should have_file_resource_count(1)

      # exec resources 1.stop system, 2. backup, and 3. start system
      should have_exec_resource_count(3)
    end

    it "should create backup directory" do
      should contain_file('/tmp/backup_redbox').with({
        :ensure => 'directory'
      }).that_comes_before('Exec[backup sources: /opt/redbox to: /tmp/backup_redbox]')
    end

    it "should stop redbox, then backup, then start redbox" do
      should contain_exec('stop redbox before backup').with({
        :command => "service redbox stop"
      })
      should contain_exec('backup sources: /opt/redbox to: /tmp/backup_redbox').with({
        :command => "/usr/bin/rsync -rcvzh --filter='- storage' --filter='- solr' --filter='- logs' /opt/redbox /tmp/backup_redbox/"
      }).that_requires('Exec[stop redbox before backup]').that_comes_before('Exec[start redbox after backup]')
      should contain_exec('start redbox after backup').with({
        :command => "service redbox start"
      })
    end
  end

  context "Given undef for 'system_name'" do
    let(:title) {'/opt/redbox'}
    let :params do
      default_params
    end
    it do
      should raise_error(Puppet::Error, /define a system name before backup/)
    end
  end

  context "Given non-absolute path for 'backup_destination_parent_path'" do
    let(:title) {'/opt/redbox'}
    let :params do
      default_params.merge({:system_name => 'redbox',
        :backup_destination_parent_path => 'tmp',})
    end
    it do
      should raise_error(Puppet::Error, /not an absolute path/)
    end
  end

end