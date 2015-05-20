require 'bundler/gem_tasks'
require 'rake'

require 'rspec/core/rake_task'
task :default => :spec
task :test => :spec
desc 'Run all specs'
RSpec::Core::RakeTask.new('spec') do |spec|
  spec.rspec_opts = %w{}
end
