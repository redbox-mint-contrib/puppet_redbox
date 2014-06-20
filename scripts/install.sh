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
puppet module install --version 4.1.0 puppetlabs/stdlib
puppet module install --version 1.0.1 puppetlabs/apache

# Pull down ReDBox Puppet configuration
yum -y install git && git clone https://github.com/redbox-mint-contrib/puppet-redbox.git /tmp/puppet-redbox && rm -Rf /tmp/puppet-redbox/.git*

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
