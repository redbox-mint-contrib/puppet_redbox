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
cd puppet_redbox
sudo bundle install
sudo rake spec
```
## Optional Features

License
-------
See file, LICENCE
