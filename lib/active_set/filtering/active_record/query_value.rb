# frozen_string_literal: true

class ActiveSet
  module Filtering
    module ActiveRecord
      module QueryValue
        def query_value
          return @query_value if defined? @query_value

          query_value = @attribute_instruction.value
          query_value = query_attribute_for(query_value)
          query_value = query_value.downcase if case_insensitive_operation?

          @query_value = query_value
        end

        private

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
