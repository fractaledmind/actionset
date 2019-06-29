# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :full_spec do
  ENV['COVERAGE'] = 'true'
  ENV['INSPECT_FAILURE'] = 'true'
  Rake::Task['spec'].invoke
end

task default: :full_spec
