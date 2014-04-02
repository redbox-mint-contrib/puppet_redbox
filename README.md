#puppet-redbox using puppet : serverless
#__________________________

This module deploys, installs and runs redbox.

## pre-install
1. run scripts/pre-install.sh to setup puppet for puppet-redbox use (run as root) 
2. follow puppet-hiera-redbox's README.md if installing private bitbucket module puppet-hiera-redbox

## install
`puppet apply -e "class {'puppet-redbox':}"`

## atm, manual configuration needed for:
1. ssl certificates and keys, including their directories
2. aaf rapid setup in home/system-config.json
3. export apiKey in home/system-config.json

* No support to run without apache proxy server.
* TODD : set up using r10k
* TODO : improve way redbox rpm build, yum and puppet integrate
* TODO : tidy up use of redbox-system to name relevant files the redbox package name, not just 'redbox'.

## ssl-config: We use hiera-gpg and a private repo to hold this data.
Our hiera config uses hashes, which in yaml looks like:
ssl_config:
  cert:
  	file:
    content: |
    
  key:
  	file:
    content: |
    
  chain:
  	file:
    content: |

License
-------
See file, LICENCE

Contact
-------


Support
-------

Please log tickets and issues at our [Projects site](http://projects.example.com)
