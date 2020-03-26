# frozen_string_literal: true

require 'gemika'
require 'combustion'

class Combustion::Database::Reset
  def call
    configuration = resettable_db_configs[Rails.env]
    adapter = configuration['adapter'] ||
              configuration['url'].split('://').first

    operator_class(adapter).new(configuration).reset
  end
end

Combustion.initialize! :active_record, :action_controller, :action_view do
  Rails.env = if Gemika::Env.gem? 'pg'
                'postgresql'
              elsif Gemika::Env.gem? 'mysql2'
                'mysql'
              else
                'sqlite'
              end
end
