require 'spec_helper'

describe 'puppet_redbox' do
  context "Given default parameters for standard redbox installation on CentOS" do
    let :facts do
      { :fqdn => 'site.domain.com.au',
        :ipaddress => '10.5.6.7',
        :ip_address_lo => '127.0.0.1',
        :osfamily => 'Redhat',
        :operatingsystem => 'CentOS',
        :operatingsystemrelease => '6.7',
        :concat_basedir => '/tmp'}
    end

    it {should compile.with_all_deps}

  end
end