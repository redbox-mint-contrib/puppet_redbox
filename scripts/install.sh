#!/bin/bash
#
# Bootstrap script for ReDBox-based systems.
#
usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage

# Install Puppet
rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
yum install -y puppet

# Install Basic Puppet Modules
puppet module install --version 1.0.2 puppetlabs/concat
puppet module install --version 4.3.2 puppetlabs/stdlib
puppet module install --version 1.1.1 puppetlabs/apache

# Pull down ReDBox Puppet configuration
yum -y install git && git clone https://github.com/redbox-mint-contrib/puppet-redbox.git /tmp/puppet-redbox && rm -Rf /tmp/puppet-redbox/.git*
# Pull down ReDBox Puppet common
git clone https://github.com/redbox-mint-contrib/puppet_common.git /usr/share/puppet/modules/puppet_common

# Double check if we have the Puppet configuration
echo "checking puppet-redbox cloned/copied to /tmp"
find /tmp -maxdepth 1 -iname "puppet-redbox" || exit 1

echo "removing existing puppet module"
rm -Rf /usr/share/puppet/modules/puppet-redbox
echo "copying redbox to module path"
cp -Rf /tmp/puppet-redbox /usr/share/puppet/modules/
echo "cleaning up tmp"
rm -Rf /tmp/puppet-redbox

# Check if we have to install other components, purposely injected here to make Hiera optional.
INSTALL_TYPE="basic"
if [ ! -z "$1" ]; then
	if [ "$1" = "harvester-complete" ]; then
		INSTALL_TYPE="$1"
		puppet module install --version 3.3.3 puppetlabs/postgresql
	else if [ ! "$1" = "basic" ]; then
			echo "Invalid installation type, specify 'basic' or 'harvester-complete'"
		exit 1
		fi
	fi
fi

# Check if we have Hiera and if so, install it.
if [ -e /tmp/puppet-hiera-redbox/scripts/install.sh ]; then
  MAIN_PUPPET_CONFIG=`puppet config print config`
  PUPPET_ENV="$2"
  if [ ! -z "$PUPPET_ENV" ]; then
    grep "$PUPPET_ENV" $MAIN_PUPPET_CONFIG
    if [ $? -ne 0 ]; then
   	  echo "[user]" >> $MAIN_PUPPET_CONFIG
      echo "   environment = $PUPPET_ENV" >> $MAIN_PUPPET_CONFIG
    fi 
  fi
  echo "Running Hiera install script..."
  /tmp/puppet-hiera-redbox/scripts/install.sh
fi

# Install ReDBox
puppet apply -e "class {'puppet-redbox': install_type=>'$INSTALL_TYPE'}"

# ReDBox admin is part of the default install
git clone https://github.com/redbox-mint-contrib/puppet_redbox_admin.git /usr/share/puppet/modules/puppet_redbox_admin
wget -O /etc/yum.repos.d/elasticsearch.repo https://raw.githubusercontent.com/redbox-mint-contrib/puppet_redbox_admin/master/support/elasticsearch.repo
chown -R redbox:redbox /tmp/redbox
puppet module install elasticsearch-elasticsearch --version 0.4.0
puppet module install elasticsearch-logstash --version 0.5.1
puppet module install maestrodev-wget --version 1.5.6
ES_CLUSTER_ID="es-cluster-`hostname`"
ES_NODE_ID="es-node-`hostname`"
puppet apply -e "class {'puppet_redbox_admin': es_clusterid=>'$ES_CLUSTER_ID', es_nodeid=>'$ES_NODE_ID'}"
