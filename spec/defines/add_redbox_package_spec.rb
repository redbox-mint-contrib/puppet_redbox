require 'spec_helper'

describe 'puppet_redbox::add_redbox_package' do
  let :default_facts do {
      :fqdn => 'site.domain.com.au',
      :hostname => 'site',
      :domain => 'domain.com.au',
      :ipaddress => '10.5.6.7',
      :ip_address_lo => '127.0.0.1',
      :osfamily => 'Redhat',
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '6.7',
      :concat_basedir => '/tmp',
  }
  end

  shared_context "stubbed params" do
    let :title do {
        'system' => 'redbox',
        'package' => 'redbox-distro',
        'server_url_context' => 'redbox',
        'install_directory' => '/opt/redbox',

      }
    end
  end
  let :default_proxy_parameters do
    [{
      'path' => '/mint',
      'url'=> 'http://localhost:9001/mint'
      },
      {
      'path' => '/redbox',
      'url'=> 'http://localhost:9000/redbox'
      },
      {
      'path' => '/oai-server',
      'url'  => 'http://localhost:8080/oai-server'
      }]
  end
  let :default_params do {
      :packages => title,
      :owner => 'redbox',
      :has_ssl => false,
      :base_server_url => '10.5.6.7',
      :proxy => default_proxy_parameters,
      :exec_path => [
      '/usr/local/bin',
      '/opt/local/bin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin']
    }
  end
  shared_context "always should" do
    it {should compile.with_all_deps}
  end
  context "given defaults for parameters" do
    let :facts do
      default_facts.merge({:environment => 'development'})
    end
    include_context "stubbed params"
    include_context "always should"
    let :params do
      default_params
    end
    it "has known set of resources" do
      should have_notify_resource_count(1)
      should have_file_resource_count(1)
      should have_exec_resource_count(2)
      should have_file_line_resource_count(1)
      should have_package_resource_count(1)
      should have_service_resource_count(1)
    end
    it "sets up pre-requisites for main package install" do
      should contain_notify('Skipping backup for /opt/redbox as NOT required in environment: development')
      should contain_file('/opt/redbox').with({:owner => 'redbox'})
        .that_comes_before('Package[redbox-distro]')
      should contain_puppet_redbox__pre_upgrade_backup('/opt/redbox').with({'system_name' => 'redbox'}).that_requires('File[/opt/redbox]').that_comes_before('Package[redbox-distro]')
    end
    it "installs the main package" do
      should contain_package('redbox-distro').with({'ensure' => 'installed'})
    end
    it "updates the main package installation" do
      should contain_file_line('update_server_url_/opt/redbox/server/tf_env.sh')
        .with({'path' => '/opt/redbox/server/tf_env.sh', 'line' => 'export SERVER_URL="http://10.5.6.7/redbox/"', 'match' => '^export SERVER_URL=".*"$'})
        .that_subscribes_to('Package[redbox-distro]')
    end
    it "starts the installed system" do
      should contain_service('redbox')
        .that_subscribes_to('Package[redbox-distro]')
      should contain_exec('redbox-restart_on_refresh').with({'command' => 'service redbox restart'})
        .that_subscribes_to('File_line[update_server_url_/opt/redbox/server/tf_env.sh]')
      should contain_exec('10.5.6.7/redbox-primer').with({'command' => 'wget --no-check-certificate --tries=2 --wait=10 --spider -O /dev/null 10.5.6.7/redbox'})
    end
  end
  context "given versioned redbox" do
    include_context "stubbed params"
    include_context "always should"
    let :params do
      default_params.merge({:packages =>  {
        'system' => 'redbox',
        'package' => 'redbox-distro',
        'server_url_context' => 'redbox',
        'install_directory' => '/opt/redbox',
        'version' => '1.8.1',
        }})
    end
    it {
      should contain_package('redbox-distro').with({'ensure' => '1.8.1'})
    }
  end
  context "given production redbox" do
    let :facts do
      default_facts.merge({:environment => 'production'})
    end
    include_context "stubbed params"
    include_context "always should"
    let :params do
      default_params
    end
    it "has known set of resources" do
      should have_file_resource_count(2)
      should have_exec_resource_count(5)
      should have_file_line_resource_count(1)
      should have_package_resource_count(1)
      should have_service_resource_count(1)
    end
    it "sets up pre-requisites, including backup, for main package install" do
      should contain_file('/opt/redbox').with({:owner => 'redbox'})
        .that_comes_before('Package[redbox-distro]')
      should contain_puppet_redbox__pre_upgrade_backup('/opt/redbox')
        .with({'system_name' => 'redbox'}).that_requires('File[/opt/redbox]')
       .that_comes_before('Package[redbox-distro]')
      should contain_exec('stop redbox before backup')
        .with({'command' => "service redbox stop || echo 'service not running'"})
        .that_requires('File[/opt/redbox]')
      should contain_file('/tmp/backup_redbox')
        .with({'ensure' => 'directory'})
        .that_comes_before('Package[redbox-distro]')
      should contain_exec('backup sources: /opt/redbox to: /tmp/backup_redbox')
        .with({'command' => "/usr/bin/rsync -rcvzh --filter='- storage' --filter='- solr' --filter='- logs' /opt/redbox /tmp/backup_redbox/"})
        .that_requires('File[/opt/redbox]')
        .that_requires('Exec[stop redbox before backup]')
        .that_requires('File[/tmp/backup_redbox]')
      should contain_exec('restart redbox after backup')
        .with({'command' => "service redbox restart || echo 'service not running'"})
          .that_requires('File[/opt/redbox]')
          .that_requires('Exec[stop redbox before backup]')
          .that_requires('File[/tmp/backup_redbox]')
          .that_requires('Exec[backup sources: /opt/redbox to: /tmp/backup_redbox]')
    end
    it "installs the main package" do
      should contain_package('redbox-distro').with({'ensure' => 'installed'})
    end
    it "updates the main package installation" do
      should contain_file_line('update_server_url_/opt/redbox/server/tf_env.sh')
        .with({'path' => '/opt/redbox/server/tf_env.sh', 'line' => 'export SERVER_URL="http://10.5.6.7/redbox/"', 'match' => '^export SERVER_URL=".*"$'})
        .that_subscribes_to('Package[redbox-distro]')
    end
    it "starts the installed system" do
      should contain_service('redbox')
        .that_subscribes_to('Package[redbox-distro]')
      should contain_exec('redbox-restart_on_refresh').with({'command' => 'service redbox restart'})
        .that_subscribes_to('File_line[update_server_url_/opt/redbox/server/tf_env.sh]')
      should contain_exec('10.5.6.7/redbox-primer').with({'command' => 'wget --no-check-certificate --tries=2 --wait=10 --spider -O /dev/null 10.5.6.7/redbox'})
    end
  end
end