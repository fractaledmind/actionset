# frozen_string_literal: true

class ActiveSet
  module Filtering
    module ActiveRecord
      module QueryColumn
        def query_column
          return @query_column if defined? @query_column

          @query_column = if must_cast_numerical_column?
                            column_cast_as_char
                          elsif must_cast_mysql_float_column?
                            column_cast_as_decimal
                          else
                            arel_column
                          end
        end

        private

        def column_cast_as_char
          # In order to use LIKE, we must CAST the numeric column as a CHAR column.
          # NOTE: this is can be quite inefficient, as it forces the DB engine to perform that cast on all rows.
          # https://www.ryadel.com/en/like-operator-equivalent-integer-numeric-columns-sql-t-sql-database/
          Arel::Nodes::NamedFunction.new('CAST', [arel_column.as('CHAR')])
        end

        def column_cast_as_decimal
          # https://dev.mysql.com/doc/refman/8.0/en/problems-with-float.html
          # In order to use equality matchers for :float fields in MySQL, we need to cast to :decimal
          Arel::Nodes::NamedFunction.new('CAST', [arel_column.as('DECIMAL(8,2)')])
        end

        def must_cast_mysql_float_column?
          return false unless ::ActiveRecord::Base.connection.adapter_name == 'Mysql2'

          arel_type == :float
        end

        def must_cast_numerical_column?
          # The LIKE operator can't be used if the column hosts numeric types.
          return false unless arel_type.presence_in(%i[integer float])

          arel_operator.to_s.downcase.include?('match')
        end
      end
    end
  end
end
