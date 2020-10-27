# frozen_string_literal: true

if ENV['INTERRUPT_FAILURE'] == 'true'
  RSpec.configure do |config|
    # http://bensnape.com/2014/08/01/rspec-after-failure-hook/
    config.after(:each) do |example|
      next unless example.exception

      byebug
    end
  end
end
