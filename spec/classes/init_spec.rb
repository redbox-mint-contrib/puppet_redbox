require 'spec_helper'

describe 'puppet_redbox' do
  shared_context "default facts" do
    let :facts do { 
      :fqdn => 'site.domain.com.au',
      :hostname => 'site',
      :domain => 'domain.com.au',
      :ipaddress => '10.5.6.7',
      :ip_address_lo => '127.0.0.1',
      :osfamily => 'Redhat',
      :operatingsystem => 'CentOS',
      :operatingsystemrelease => '6.7',
      :concat_basedir => '/tmp'}
    end
  end
  shared_context "always should" do
    it {should compile.with_all_deps}
    it {
         should contain_package('java')
         should contain_class('puppet_redbox::add_proxy_server')
         should contain_yumrepo('redbox_releases')
         should contain_yumrepo('redbox_snapshots')
         should contain_service('httpd')
         should contain_exec('service httpd restart')
       }
    it {
        should contain_tidy('/var/lib/puppet/reports').with({
          :age     => '1w',
          :recurse => true,
          :matches => ['*.yaml']})
       }
  end
  let :default_redbox_package_parameters do {
        'system' => 'redbox',
        'package' => 'redbox-distro',
        'server_url_context' => 'redbox',
        'install_directory' => '/opt/redbox'
  }
  end
  let :default_mint_package_parameters do {
        'system' => 'mint',
        'package' => 'mint-distro',
        'server_url_context' => 'mint',
        'install_directory' => '/opt/mint',
        'pre_install'         => 'unzip',
        'post_install'        => [
        'mint-solr-geonames',
        'mint-build-distro-initial-data']
  }
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
  context "Given default parameters for standard redbox installation on CentOS" do
    include_context "default facts"
    include_context "always should"
    let :params do {
          'packages' => { 
                  'redbox' => default_redbox_package_parameters, 
                  'mint' => default_mint_package_parameters
          },
          'proxy' => default_proxy_parameters
    }
    end

    it 'Given fqdn: site.domain.com.au' do
      should contain_host('site.domain.com.au')
      should contain_host('site')
    end

    it 'Given default parameters' do
      should contain_user('redbox')
      should contain_file('/opt').with({:ensure => 'directory',
              :owner => 'root',
              :group => 'root',
              :mode => '0755'})
      should_not contain_puppet_common__add_cron
      should_not contain_puppet_redbox__add_harvesters_complete
    end
 
    it 'Given proxy' do
      should contain_class('puppet_redbox::add_proxy_server')
        .with({
          :server_url => '10.5.6.7',
          :has_ssl => false,
          :ssl_config => {
            'cert'  => {
              'file'  => "/etc/ssl/local_certs/site.domain.com.au.crt"
            },
            'key'   => {
              'file' => "/etc/ssl/local_certs/site.domain.com.au.key",
              'mode' => '0444'
            },
            'chain' => {
              'file'  => "/etc/ssl/local_certs/site.domain.com.au.chain"
            }
          },
          :proxy => default_proxy_parameters
        })
        .that_requires('Package[java]')
        .that_comes_before("Puppet_redbox::Add_redbox_package[#{default_redbox_package_parameters}]")
        .that_comes_before("Puppet_redbox::Add_redbox_package[#{default_mint_package_parameters}]")
        .that_notifies('Service[httpd]')
      
      should contain_exec('service httpd restart')
        .that_requires("Puppet_redbox::Add_redbox_package[#{default_redbox_package_parameters}]")
        .that_requires("Puppet_redbox::Add_redbox_package[#{default_mint_package_parameters}]")
    end
    
    let :default_add_package_parameters do
      {
        :owner           => 'redbox',
        :has_ssl         => false,
        :tf_env => '',
        :system_config => '',
        :base_server_url => '10.5.6.7',
        :proxy           => default_proxy_parameters
      }
    end
    it {
      should contain_puppet_redbox__add_redbox_package(default_redbox_package_parameters).with(default_add_package_parameters)
        .that_requires(['User[redbox]','Package[java]'])
        .that_comes_before('Exec[service httpd restart]')
      should contain_puppet_redbox__add_redbox_package(default_mint_package_parameters).with(default_add_package_parameters)
        .that_requires(['User[redbox]','Package[java]'])
        .that_comes_before('Exec[service httpd restart]')
    }
  end
end