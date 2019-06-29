# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require 'simplecov'
require 'simplecov-console'
require 'codecov'

if ENV['COVERAGE'] == 'true'
  ROOT = File.expand_path('..', __dir__)

  # SimpleCov.minimum_coverage 99
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
                                                                   SimpleCov::Formatter::HTMLFormatter,
                                                                   SimpleCov::Formatter::Console,
                                                                   SimpleCov::Formatter::Codecov
                                                                 ])
  SimpleCov.start 'rails' do
    %w[
      lib/active_set/version.rb
    ].each do |ignorable|
      add_filter ignorable
    end
  end
end
