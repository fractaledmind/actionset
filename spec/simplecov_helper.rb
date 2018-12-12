ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-console'
unless ENV['COVERAGE'] == 'false'
  ROOT = File.expand_path('..', __dir__)

  # SimpleCov.minimum_coverage 100
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ])
  SimpleCov.start 'rails' do
    track_files 'engines/**/*.rb'
    %w(
      lib/action_set/version.rb
    ).each do |ignorable|
      add_filter ignorable
    end
  end
end
