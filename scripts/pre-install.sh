#!/bin/bash

usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage

rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
yum install -y puppet
puppet module install --version 1.0.2 puppetlabs/concat
puppet module install --version 4.1.0 puppetlabs/stdlib
puppet module install --version 1.0.1 puppetlabs/apache

echo "checking puppet-redbox cloned/copied to /tmp"
find /tmp -maxdepth 1 -iname "puppet-redbox" || exit 1

echo "removing existing puppet module"
rm -Rf /usr/share/puppet/modules/puppet-redbox
echo "copying redbox to module path"
cp -Rf /tmp/puppet-redbox /usr/share/puppet/modules/
echo "cleaning up tmp"
rm -Rf /tmp/puppet-redbox
