# frozen_string_literal: true

class ActiveSet
  module Filtering
    module ActiveRecord
      module QueryValue
        def query_value
          return @query_value if defined? @query_value

          @query_value = prepare_query_value(@attribute_instruction.value)
        end

        private

        def prepare_query_value(value)
          return value.map { |v| prepare_query_value(v) } if value.respond_to?(:map) && !arel_operator.to_s.downcase.include?('between')

          value = query_attribute_for(value)
          value = value.downcase if case_insensitive_operation?

          if arel_type == :time && arel_operator.to_s.downcase.include?('match')
            value = value.remove('2000-01-01 ')
            value = value.remove('.000000')
          end

          value
        end

        def query_attribute_for(value)
          return value unless operator_hash.key?(:query_attribute_transformer)

          context = {
            raw: value,
            sql: to_sql_str(value),
            type: arel_type
          }

          operator_hash[:query_attribute_transformer].call(context)
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
      end
    end
  end
end
