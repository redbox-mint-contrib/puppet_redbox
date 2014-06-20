#puppet-redbox using puppet : serverless
This module deploys, installs and runs redbox.

## Pre-requisites
*Tested only on CentOS 6 64bit*

## Installation

1. Download the installation bootstrap script.
```
wget https://raw.githubusercontent.com/redbox-mint-contrib/puppet-redbox/master/scripts/install.sh && chmod +x install.sh

```
2. Execute the script as root.
```
sudo install.sh
```
## Optional Features

1. Follow puppet-hiera-redbox's README.md if installing bitbucket module puppet-hiera-redbox

## Manual configuration needed for:
* export apiKey in home/system-config.json

##TODO:
* set up using r10k/heat
* improve way redbox rpm build, yum and puppet integrate

License
-------
See file, LICENCE
