#!/bin/sh

usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage

pkill -u redbox
userdel -rf redbox

rm -Rf /opt/deploy
rm -Rf /opt/redbox
rm -Rf /opt/mint

yum erase -y java
yum erase -y httpd
yum erase -y redbox

## Uncomment below if also resetting ruby and puppet installation
#rm -Rf /usr/local/rvm
#rm -Rf /etc/puppet
#rm -Rf /usr/share/puppet
