require 'spec_helper'

describe 'puppet_redbox::move_and_link_directory' do
  let!(:create_parent_directories) { MockFunction.new('create_parent_directories', {:type => :statement})
  }
  
  let :default_params do
    {
      :target => title,
      :relocation => '/mnt/data',
      :owner => 'redbox'
    }
  end

  context "Given default parameters for redbox/storage" do
    let (:title) {'redbox/storage'}
    let :params do
      default_params.merge({:target_parent => '/opt'})
    end

    it {should compile.with_all_deps}
    it "has a known and consistent number of resources" do
      should have_resource_count(5)

      # file should 1. ensure destination 2. link back to original
      should have_exec_resource_count(2)
      should have_file_resource_count(2)
    end

    it do
      should contain_file('/mnt/data/redbox/storage').with({
        :ensure => 'directory',
        :owner => 'redbox'
      }).that_comes_before('Exec[cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/]')

      should contain_exec('cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/').with({
        :unless => 'test -h /opt/redbox/storage'
      }).that_comes_before('Exec[rm -Rf /opt/redbox/storage && ln -sf /mnt/data/redbox/storage /opt/redbox/storage]')
      .that_requires('File[/mnt/data/redbox/storage]')

      should contain_exec('rm -Rf /opt/redbox/storage && ln -sf /mnt/data/redbox/storage /opt/redbox/storage').with({
        :unless => 'test -h /opt/redbox/storage'
      })
      .that_requires('Exec[cp -pRf /opt/redbox/storage/* /mnt/data/redbox/storage/]')
      .that_comes_before('File[/opt/redbox/storage]')

      should contain_file('/opt/redbox/storage').with({
        :ensure => 'link',
        :owner => 'redbox',
        :force => 'true',
        :target => '/mnt/data/redbox/storage'}).that_requires('Exec[rm -Rf /opt/redbox/storage && ln -sf /mnt/data/redbox/storage /opt/redbox/storage]')

    end
  end
  
  context "Given default parameters for /opt/redbox/home/logs" do
      let (:title) {'/opt/redbox/home/logs'}
      let :params do
        default_params.merge({:relocation => '/mnt/logs/redbox'})
      end
  
      it {should compile.with_all_deps}
      it "has a known and consistent number of resources" do
        should have_resource_count(5)
  
        # file should 1. ensure destination 2. link back to original
        should have_exec_resource_count(2)
        should have_file_resource_count(2)
      end
  
      it do
        should contain_file('/mnt/logs/redbox').with({
          :ensure => 'directory',
          :owner => 'redbox',
        }).that_comes_before('Exec[cp -pRf /opt/redbox/home/logs/* /mnt/logs/redbox/]')
  
        should contain_exec('cp -pRf /opt/redbox/home/logs/* /mnt/logs/redbox/').with({
          :unless => 'test -h /opt/redbox/home/logs'
        }).that_comes_before('Exec[rm -Rf /opt/redbox/home/logs && ln -sf /mnt/logs/redbox /opt/redbox/home/logs]')
        .that_requires('File[/mnt/logs/redbox]')
  
        should contain_exec('rm -Rf /opt/redbox/home/logs && ln -sf /mnt/logs/redbox /opt/redbox/home/logs').with({
          :unless => 'test -h /opt/redbox/home/logs'
        })
        .that_requires('Exec[cp -pRf /opt/redbox/home/logs/* /mnt/logs/redbox/]')
        .that_comes_before('File[/opt/redbox/home/logs]')
  
        should contain_file('/opt/redbox/home/logs').with({
          :ensure => 'link',
          :owner => 'redbox',
          :force => 'true',
          :target => '/mnt/logs/redbox'}).that_requires('Exec[rm -Rf /opt/redbox/home/logs && ln -sf /mnt/logs/redbox /opt/redbox/home/logs]')
  
      end
    end
end