#puppet_redbox using puppet : serverless
This module deploys, installs and runs redbox.

## Pre-requisites
*Tested only on CentOS 6 64bit*

## Installation

1. Download the installation bootstrap script.
```
wget https://raw.githubusercontent.com/redbox-mint-contrib/puppet_redbox/master/scripts/install.sh && chmod +x install.sh

```
2. Execute the script as root.
```
sudo install.sh
```

3. Test module.

```
sudo rake spec
```
## Optional Features

1. Follow puppet-hiera-redbox's README.md if installing bitbucket module puppet-hiera-redbox


License
-------
See file, LICENCE
