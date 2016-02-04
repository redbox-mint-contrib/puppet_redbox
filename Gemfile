# `bundle install` to setup requirements to run puppet and/or tests
source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['= 3.8.4']
gem 'puppet', puppetversion
gem 'facter', '>=2.2.6', 					:require => false

# code style/validation
gem 'puppet-lint', '>=0.3.2', 				:require => false
gem 'metadata-json-lint', '>=0.0.11', 		:require => false

# unit testing and coverage
gem 'puppetlabs_spec_helper', '>=0.1.0', 	:require => false
gem 'rspec-puppet-utils', '>=2.0.0', 		:require => false

# acceptance testing
gem 'beaker-rspec', '>=5.2.0',  			:require => false
gem 'serverspec', 							:require => false