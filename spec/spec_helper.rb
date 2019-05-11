# frozen_string_literal: true

require 'simplecov_helper'

require 'bundler'
require 'combustion'
Combustion.initialize! :active_record, :action_controller, :action_view
Bundler.require :default, :development

require 'bundler/setup'
require 'ostruct'
require 'csv'
require 'action_set'
require 'active_set'
require 'rspec/rails'
require 'database_cleaner'
require 'capybara/rspec'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

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

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:all) do
    DatabaseCleaner.start
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end

  # Give a detailed report of all relevant data if a spec fails
  # http://bensnape.com/2014/08/01/rspec-after-failure-hook/
  config.after(:each) do |example|
    next unless example.exception

    let_data = @__memoized.instance_variable_get('@memoized')
    ivar_data = instance_variables
      .reject { |v| v.to_s.start_with?('@_') }
      .reject { |v| v.presence_in %i[@example @fixture_cache @fixture_connections @connection_subscriber @loaded_fixtures] }
      .map { |v| [v, instance_variable_get(v)] }
      .to_h

    # https://www.jvt.me/posts/2019/03/29/pretty-printing-json-ruby/
    jj let_data.merge(ivar_data).transform_values(&:inspect)
  end
end
