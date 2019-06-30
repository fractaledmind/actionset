# frozen_string_literal: true

require_relative '../../active_record_set_instruction'
require_relative './operators'

class ActiveSet
  module Filtering
    module ActiveRecord
      class SetInstruction < ActiveRecordSetInstruction
        def arel_operator
          operator_hash.fetch(:operator, :eq)
        end

        def arel_value
          return @arel_value if defined? @arel_value

          arel_value = guarantee_attribute_type(@attribute_instruction.value)
          arel_value = query_attribute_for(arel_value)
          arel_value = arel_value.downcase if case_insensitive_operation?

          @arel_value = arel_value
        end

        private

        def query_attribute_for(value)
          return value unless operator_hash.key?(:query_attribute_transformer)

          operator_hash[:query_attribute_transformer].call(value)
        end

        def operator_hash
          instruction_operator = @attribute_instruction.operator

          Operators.get(instruction_operator)
        end

        def guarantee_attribute_type(attribute)
          # Booleans don't respond to many operator methods,
          # so we cast them to however the database expects them
          return attribute if not arel_type == :boolean
          return attribute.map { |a| guarantee_attribute_type(a) } if attribute.respond_to?(:each)

          sql_value = Arel::Nodes::Casted.new(attribute, arel_column).to_sql
          sql_value = sql_value[/'(.*?)'/, 1] if sql_value.match? /'.*?'/
          sql_value
        end
      end
    end
  end
end
