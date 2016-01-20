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
mkdir -p /var/log/puppet

# Install Ruby and Puppet
export RUBY_VERSION=2.0.0-p598
export PUPPET_VERSION=3.8.4

# grab tool to download scripts
yum -y install wget

export PUPPET_INSTALL_DIR=/tmp/ruby_puppet
mkdir -p ${PUPPET_INSTALL_DIR}
wget -N -O ${PUPPET_INSTALL_DIR}/install.sh https://raw.githubusercontent.com/redbox-mint-contrib/ruby_puppet/master/Centos/install.sh 
chmod +x ${PUPPET_INSTALL_DIR}/install.sh
${PUPPET_INSTALL_DIR}/install.sh
PUPPET_DIR=/etc/puppet
mkdir -p /etc/puppet

# redbox install
