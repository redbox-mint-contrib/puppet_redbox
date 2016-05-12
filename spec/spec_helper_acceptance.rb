require 'beaker-rspec'

redbox_script = ['scripts/install.sh']
puppet_conf = ['spec/resources/puppet.conf']
master_fqdn = ""
ruby_version = "2.0.0-p598"
puppet_version = "3.8.4"
if any_hosts_as?('master')
  on master, "rpm -Uvh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm"
  on master, "yum install -y puppet"
  on master, "yum -y update"
  on master, "yum update -y ruby"
  on master, "yum update -y puppet"
  on master, "facter fqdn" do
    master_fqdn = stdout
  end
  on master, "touch /etc/puppet/autosign.conf"
  on master, "echo '*' > /etc/puppet/autosign.conf"
  on master, "hostname #{master_fqdn}"
  config = {
    'main' => {
    'logdir'   => '/var/log/puppet',
    'vardir'   => '/var/lib/puppet',
    'ssldir'   => '/var/lib/puppet/ssl',
    'rundir'   => '/var/run/puppet'
    },
    'agent' => {
    'classfile' => '/var/lib/puppet/classes.txt',
    'localconfig' => '/var/lib/puppet/localconfig'
    }
  }
  configure_puppet_on(master, config)
  on master, "cat /etc/hosts"
  on master, "cat /etc/puppet/puppet.conf"
  on master, "ruby --version"
  on master, "puppet --version"
  deploy_dir = "/tmp"
  on master, "mkdir -p #{deploy_dir}"
  copy_module_to master, :target_module_path => deploy_dir
  ## clone any git module dependencies
  git_dependencies = ["puppet_common"]
  on master, "yum install -y git"
  git_dependencies.each do |d|
    clone_git_repo_on master, "/tmp", {:name => "puppet_common", :path => "https://github.com/redbox-mint-contrib/puppet_common.git", :rev => "master"}
  end
  ## install modules, including dependencies
  on master, "yum install -y tar"
  (["puppet_redbox"].concat(git_dependencies)).each do |puppet_module|
    on master, "tar -Pcvz #{deploy_dir}/#{puppet_module} -f #{deploy_dir}/#{puppet_module}.tar.gz --exclude=#{deploy_dir}/#{puppet_module}/.git"
    on master, "puppet module install #{deploy_dir}/#{puppet_module}.tar.gz"
  end
  ## add site manifest
  on master, "mkdir -p /etc/puppet/manifests"
  on master, "touch /etc/puppet/manifests/site.pp"
  on master, 'echo "node default { class {\'puppet_redbox\': if_fresh_install => true} }" > /etc/puppet/manifests/site.pp'
  on master, "cat /etc/puppet/manifests/site.pp"
  on master, "puppet master -d"
  on master, "ps -efl | grep puppet"
  on agents, "yum install -y git"
  clone_git_repo_on agents, "/tmp", {:name => "ruby_puppet", :path => "https://github.com/redbox-mint-contrib/ruby_puppet.git", :rev => "master"}
  on agents, "chmod +x /tmp/ruby_puppet/Centos/install.sh"
  on agents, "export RUBY_VERSION=#{ruby_version};export PUPPET_VERSION=#{puppet_version};/tmp/ruby_puppet/Centos/install.sh"
  on agents, "source /root/.bashrc && ruby --version && puppet --version"
  on agents, "mkdir -p /etc/puppet"
  on agents, "touch /etc/puppet/puppet.conf"
  configure_puppet_on(agents, config)
  on agents, "echo \"server=#{master_fqdn}\" >> /etc/puppet/puppet.conf"
  on agents, "cat /etc/hosts"
  on agents, "cat /etc/puppet/puppet.conf"
  on agents, "sleep 5 && puppet agent --test --detailed-exitcodes --waitforcert 30", :acceptable_exit_codes => [0,2,6]
else
  hosts.each do |host|
    scp_to host, File.expand_path(File.join(File.dirname(__FILE__), '..', redbox_script)), "/tmp/install.sh"
    on host, "chmod +x /tmp/install.sh"
    on host, "bash -l -c /tmp/install.sh"
  end
end

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
  end
end