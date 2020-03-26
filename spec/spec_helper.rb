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
