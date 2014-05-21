#puppet-redbox using puppet : serverless
This module deploys, installs and runs redbox.

## Pre-requisites
*Tested only on CentOS 6 64bit*

1.Clone/copy puppet-redbox
```
sudo yum -y install git && git clone https://github.com/redbox-mint-contrib/puppet-redbox.git /tmp/puppet-redbox && rm -Rf /tmp/puppet-redbox/.git*
```
2.setup puppet for puppet-redbox use (run as root)
```
sudo /tmp/puppet-redbox/scripts/pre-install.sh
```

3.follow puppet-hiera-redbox's README.md if installing bitbucket module puppet-hiera-redbox

## Install
```
sudo puppet apply -e "class {'puppet-redbox':}"
```

## Manual configuration needed for:
* export apiKey in home/system-config.json

##TODO:
* set up using r10k/heat
* improve way redbox rpm build, yum and puppet integrate

License
-------
See file, LICENCE
