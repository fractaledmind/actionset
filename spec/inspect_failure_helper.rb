# frozen_string_literal: true

if ENV['INSPECT_FAILURE'] == 'true'
  RSpec.configure do |config|
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
end
