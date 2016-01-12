require 'spec_helper'

describe 'puppet_redbox' do
  shared_context "default redbox_package" do
    let :redbox_package do {
        'system' => 'redbox',
        'package' => 'redbox-distro',
        'server_url_context' => 'redbox',
        'install_directory' => '/opt/redbox',
        'institutional_build' => :undef,
      }
    end
    let :mint_package do
      {
        'system' => 'mint',
        'package' => 'mint-distro',
        'server_url_context' => 'mint',
        'install_directory' => '/opt/mint',
        'pre_install'         => 'unzip',
        'post_install'        => [
        'mint-solr-geonames',
        'mint-build-distro-initial-data'],
        'institutional_build' => :undef
      }
    end
    let :proxy do
      [ {
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
        }
      ]
    end
  end
  context "Given default parameters for standard redbox installation on CentOS" do
    include_context "default redbox_package"
    let :facts do
      { :fqdn => 'site.domain.com.au',
        :hostname => 'site',
        :domain => 'domain.com.au',
        :ipaddress => '10.5.6.7',
        :ip_address_lo => '127.0.0.1',
        :osfamily => 'Redhat',
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '6.7',
        :concat_basedir => '/tmp'}
    end

    it {should compile.with_all_deps}

    it {
      should contain_host('site.domain.com.au')
      should contain_host('site')
    }

    it {
      should contain_user('redbox')
    }

    it {
      should contain_file('/opt').with({:ensure => 'directory',
        :owner => 'root',
        :group => 'root',
        :mode => '0755'})
    }

    it {
      should contain_package('java')
      should contain_class('puppet_redbox::add_proxy_server')
      should contain_yumrepo('redbox_releases')
      should contain_yumrepo('redbox_snapshots')
      should contain_service('httpd')
      should contain_exec('service httpd restart')
    }
    
    it {
      should_not contain_puppet_common__add_cron
      should_not contain_puppet_redbox__add_harvesters_complete
    }

    it {
      should contain_puppet_redbox__add_redbox_package(redbox_package).with({
        :owner           => 'redbox',
        :has_ssl         => false,
        :base_server_url => '10.5.6.7',
        :proxy           => proxy
      }).that_requires(['Puppet_common::Add_systemuser[redbox]','Class[Puppet_common::Java]'])
        .that_notifies('Service[httpd]')
        .that_comes_before('Exec[service httpd restart]')
      should contain_puppet_redbox__add_redbox_package(mint_package).with({
        :owner           => 'redbox',
        :has_ssl         => false,
        :base_server_url => '10.5.6.7',
        :proxy           => proxy
      }).that_requires(['Puppet_common::Add_systemuser[redbox]','Class[Puppet_common::Java]'])
      .that_notifies('Service[httpd]')
      .that_comes_before('Exec[service httpd restart]')
    }

  end
end