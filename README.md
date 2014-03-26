#redbox using puppet : serverless
#__________________________

This module deploys, installs and runs redbox.

## pre-install
1. run scripts/pre-install.sh to setup puppet for redbox use.
2. requires hiera configuration

## install
`puppet apply -e "class {'puppet-redbox':}"`

## atm, manual configuration needed for:
1. ssl certificates and keys, including their directories
2. aaf rapid setup in home/system-config.json
3. export apiKey in home/system-config.json

## No support to run without apache proxy server.
* Tested only on CentOS
* TODD : set up using r10k
* TODO : use gpg pattern for handling SSL certs and keys
* TODO : improve way redbox rpm build, yum and puppet integrate

License
-------
See file, LICENCE

Contact
-------


Support
-------

Please log tickets and issues at our [Projects site](http://projects.example.com)
