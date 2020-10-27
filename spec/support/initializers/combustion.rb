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

  if ActiveRecord::VERSION::MAJOR < 6 &&
      config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

  if ActiveRecord::VERSION::MAJOR <= 4 && Gemika::Env.gem?('pg')
    # pg 1.0 gem has removed these constants, but 4.2 ActiveRecord still expects them
    PGconn   = PG::Connection
    PGresult = PG::Result
    PGError  = PG::Error
  end
end
