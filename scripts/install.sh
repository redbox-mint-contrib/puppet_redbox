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

export LOG_DEST=/var/log/puppet/puppet.log

# Install Puppet
#rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
#yum install -y puppet
touch $LOG_DEST

# Install Basic Puppet Modules
#puppet module install --force --version 1.0.2 puppetlabs/concat
#puppet module install --force --version 4.3.2 puppetlabs/stdlib
#puppet module install --force --version 1.1.1 puppetlabs/apache


## placed here instead of puppet as temp workaround
#yum install -y yum-priorities

#yum -y install git

install_git_module() {
    git_owner=redbox-mint-contrib
    echo "installing module: $1"
    # Pull down ReDBox Puppet configuration
    git clone https://github.com/$git_owner/$1.git /tmp/$1 && rm -Rf /tmp/$1/.git*
    
    # Double check if we have the Puppet configuration
    echo "checking $1 cloned/copied to /tmp"
    find /tmp -maxdepth 1 -iname "$1" || exit 1
    
    echo "removing existing puppet module"
    rm -Rf /usr/share/puppet/modules/$1
    echo "copying $1 to module path"
    cp -Rf /tmp/$1 /usr/share/puppet/modules/
    echo "cleaning up tmp"
    rm -Rf /tmp/$1
}

#install_git_module puppet_redbox
#install_git_module puppet_common

##TODO : NB: debug code -remove!!!
rm -Rf /usr/share/puppet/modules/puppet_redbox
cp -R /home/ec2-user/puppet_redbox /usr/share/puppet/modules
rm -Rf /usr/share/puppet/modules/puppet_common
cp -R /home/ec2-user/puppet_common /usr/share/puppet/modules

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
puppet apply --logdest ${LOG_DEST} -e "class {'puppet_redbox': install_type=>'$INSTALL_TYPE'}"

