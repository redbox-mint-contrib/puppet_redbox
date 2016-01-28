require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

# erase coverage task for rcov, which does not work
Rake::Task[:coverage].clear
desc "Run spec tests with full output and generate code coverage information"
RSpec::Core::RakeTask.new(:spec_coverage) do |t|
  Rake::Task[:spec_prep].invoke
  t.rspec_opts = ['--color --format d']
  t.pattern = 'spec/{classes,defines,unit,functions,hosts,integration,types}/**/*_spec.rb'
  ENV['COVERAGE'] = "true"
end

