# frozen_string_literal: true

require 'bundler'
require 'support/combustion_helper'
Bundler.require :default, :development

require 'bundler/setup'
require 'ostruct'
require 'csv'
require 'action_set'
require 'active_set'
require 'rspec/rails'
require 'database_cleaner'
require 'capybara/rspec'
require 'gemika'

database = Gemika::Database.new(config_folder: 'spec/internal/config')
database.connect

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

# "DEPRECATION WARNING: You attempted to assign a value which is not explicitly `true` or `false` () to a boolean column. Currently this value casts to `false`. This will change to match Ruby's semantics, and will cast to `true` in Rails 5. If you would like to maintain the current behavior, you should explicitly handle the values you would like cast to `false`. (called from typecast at /Users/margheim/Dropbox/gems/actionset/lib/action_set/attribute_value.rb:98)
deprecation_warnings_to_silence = [
  /attempted to assign a value which is not explicitly `true` or `false`/,
  /`#column_for_attribute` will return a null object for non-existent columns in Rails 5. Use `#has_attribute?/,
  /warning: BigDecimal.new is deprecated; use BigDecimal() method instead./,
  /rb_check_safe_obj will be removed in Ruby 3.0/,
  /Capturing the given block using Proc.new is deprecated/,
]

ActiveSupport::Deprecation.behavior = lambda do |message, callstack|
  unless message =~ Regexp.new(deprecation_warnings_to_silence.join('|'))
    ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:stderr].call(message, callstack)
  end
end

RSpec.configure do |config|
  include PathHelpers
  include FilteringHelpers
  include SortingHelpers
  include FactoryHelpers

  config.mock_with :rspec
  config.order = 'random'

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    begin
      FactoryBot.find_definitions
    rescue FactoryBot::DuplicateDefinitionError
      nil
    end
  end
end
