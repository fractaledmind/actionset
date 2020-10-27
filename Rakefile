# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

begin
  require 'gemika/tasks'
rescue LoadError
  puts 'Run `gem install gemika` for additional tasks'
end

RSpec::Core::RakeTask.new(:spec)

task :custom_default do
  ENV['COVERAGE'] = 'true'
  ENV['INSPECT_FAILURE'] = 'true'
  ENV['LOGICALLY_EXHAUSTIVE_REQUEST_SPECS'] = 'true'
  Rake::Task['matrix:spec'].invoke
end

task default: :custom_default
