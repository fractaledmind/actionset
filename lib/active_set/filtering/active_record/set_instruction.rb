# frozen_string_literal: true

require_relative '../../active_record_set_instruction'
require_relative './operators'

class ActiveSet
  module Filtering
    module ActiveRecord
      class SetInstruction < ActiveRecordSetInstruction
        def arel_operator
          instruction_operator = @attribute_instruction.operator
          operator_hash = Operators.get(instruction_operator)

          operator_hash.fetch(:operator, :eq)
        end

        def query_value
          return @query_value if defined? @query_value

          value = @attribute_instruction.value

          adapter_is_mysql = adapter_type.presence_in(%i[mysql mysql2])
          arel_column = attribute_model.column_for_attribute(attribute)
          arel_column_scale = arel_column&.scale
          value = begin
            if value.respond_to?(:map)
              value.map do |v|
                if v.respond_to?(:map)
                  v.map { |vv| sprintf("%0.#{arel_column_scale}f", vv) }
                else
                  sprintf("%0.#{arel_column_scale}f", v)
                end
              end
            else
              sprintf("%0.#{arel_column_scale}f", value)
            end
          end if adapter_is_mysql && arel_column_scale

          instruction_operator = @attribute_instruction.operator
          operator_hash = Operators.get(instruction_operator)
          operator_has_transformer = operator_hash.key?(:query_attribute_transformer)
          value = begin
            context = {
              raw: value,
              sql: to_sql_str(value),
              type: arel_type
            }

            operator_hash[:query_attribute_transformer].call(context)
          end if operator_has_transformer

          value = value.downcase if case_insensitive_operation?

          arel_type_is_time = arel_type == :time
          arel_operator_is_match_type = arel_operator.to_s.downcase.include?('match')
          value = begin
            if value.respond_to?(:map)
              value.map do |v|
                if v.respond_to?(:map)
                  v.map { |vv| vv.remove('2000-01-01 ').remove('.000000') }
                else
                  v.remove('2000-01-01 ').remove('.000000')
                end
              end
            else
              value.remove('2000-01-01 ')
                   .remove('.000000')
            end
          end if arel_type_is_time && arel_operator_is_match_type && adapter_is_mysql

          # return value.map { |v| prepare_query_value(v) } if value.respond_to?(:map) && !arel_operator.to_s.downcase.include?('between')

          @query_value = value
        end

        def query_column
          return @query_column if defined? @query_column

          adapter_is_mysql = adapter_type.presence_in(%i[mysql mysql2])
          arel_type_is_float = arel_type == :float
          arel_type_integer_or_float = arel_type.presence_in(%i[integer float])
          arel_operator_is_match_type = arel_operator.to_s.downcase.include?('match')
          query_value_is_numeric = query_value.is_a?(Numeric)
          query_value_is_collection_of_numerics = (query_value.respond_to?(:flatten) && query_value.flatten.all? { |qv| qv.is_a?(Numeric) })
          query_value_is_range_of_numerics = query_value.is_a?(Range) && query_value.begin.is_a?(Numeric)
          arel_type_is_string_or_text_or_binary = arel_type.presence_in(%i[string text binary])
          arel_operator_is_between_type = arel_operator.to_s.downcase.include?('between')

          if adapter_is_mysql
            activerecord_result_encoding_info = ::ActiveRecord::Base.connection.exec_query(<<~SQL)
              SELECT character_set_name, collation_name
              FROM information_schema.`COLUMNS`
              WHERE table_schema = '#{::ActiveRecord::Base.connection.current_database}'
              AND table_name = '#{attribute_model.table_name}'
              AND column_name = '#{arel_column_name}'
            SQL
            encoding_info = activerecord_result_encoding_info.to_a.first
            # "character_set_name", "collation_name"
            encoding_to_comparison_collation_mapping = {
              'utf8mb4' => 'utf8mb4_bin',
              'utf8' => 'utf8_bin',
              'latin1' => 'latin1_bin'
            }
            character_set = encoding_info['character_set_name']
            comparison_collation = encoding_to_comparison_collation_mapping[character_set]
            arel_column_collation_is_not_comparable = encoding_info['collation_name'] != comparison_collation
          else
            arel_column_collation_is_not_comparable = false
          end

          @query_column = if arel_type_integer_or_float && arel_operator_is_match_type
                            # In order to use LIKE, we must CAST the column as a CHAR column.
                            # NOTE: this is can be quite inefficient, as it forces the DB engine to perform that cast on all rows.
                            # https://www.ryadel.com/en/like-operator-equivalent-integer-numeric-columns-sql-t-sql-database/
                            if adapter_type == :postgresql
                              Arel::Nodes::NamedFunction.new('CAST', [arel_column.as('TEXT')])
                            else
                              Arel::Nodes::NamedFunction.new('CAST', [arel_column.as('CHAR')])
                            end
                          elsif adapter_is_mysql && arel_type_is_float && (query_value_is_numeric || query_value_is_collection_of_numerics || query_value_is_range_of_numerics)
                            # In order to use equality matchers for :float fields in MySQL, we need to cast to :decimal
                            # https://dev.mysql.com/doc/refman/8.0/en/problems-with-float.html
                            Arel::Nodes::NamedFunction.new('CAST', [arel_column.as('DECIMAL(8,2)')])
                          elsif arel_type_is_string_or_text_or_binary && arel_operator_is_between_type && arel_column_collation_is_not_comparable
                            Arel.sql("#{arel_column_to_sql(arel_column)} COLLATE #{comparison_collation}")
                          elsif adapter_type == :postgresql && arel_type == :boolean
                            Arel::Nodes::NamedFunction.new('CAST', [arel_column.as('TEXT')])
                          else
                            arel_column
                          end
        end

        private

        def adapter_type
          return @adapter_type if defined? @adapter_type

          @adapter_type = ::ActiveRecord::Base.connection
                                              .adapter_name
                                              .downcase
                                              .to_sym
        end

        def to_sql_str(value)
          return value.map { |a| to_sql_str(a) } if value.respond_to?(:map)
          return value if arel_type == :binary

          arel_node = Arel::Nodes::Casted.new(value, arel_column)
          sql_value = arel_node.to_sql
          unwrap_sql_str(sql_value)
        end

        def unwrap_sql_str(sql_str)
          return sql_str unless sql_str[0] == "'" && sql_str[-1] == "'"

          sql_str[1..-2]
        end

        def arel_column_to_sql(arel_column)
          # the ARel column can already be rendered as SQL (because it is wrapped in a LOWER function, for example)
          if arel_column.respond_to?(:to_sql)
            arel_column.to_sql
          else
            arel_column.eq(nil).to_sql.remove(' IS NULL')
          end
        end
      end
    end
  end
end
