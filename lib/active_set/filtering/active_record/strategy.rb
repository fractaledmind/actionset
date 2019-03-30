# frozen_string_literal: true

require_relative './attribute_set_instruction'
require 'active_support/core_ext/module/delegation'
require 'active_record/errors'

class ActiveSet
  module Filtering
    module ActiveRecord
      class Strategy
        include Constants

        delegate :attribute_model,
                 :arel_column,
                 :arel_operator,
                 :arel_value,
                 :arel_type,
          to: :@attribute_set_instruction

        def initialize(set, attribute_instruction)
          @set = set
          @attribute_set_instruction = AttributeSetInstruction.new(attribute_instruction, @set)
        end

        def execute
          return false unless @set.respond_to? :to_sql

          if execute_where_operation?
            statement = where_operation
          elsif execute_merge_operation?
            statement = merge_operation
          else
            return false
          end

          statement
        end

        private

        def execute_where_operation?
          return false unless attribute_model
          return false unless attribute_model.respond_to?(:attribute_names)
          return false unless attribute_model.attribute_names.include?(@attribute_set_instruction.attribute)

          true
        end

        def execute_merge_operation?
          return false unless attribute_model
          return false unless attribute_model.respond_to?(@attribute_set_instruction.attribute)
          return false if attribute_model.method(@attribute_set_instruction.attribute).arity.zero?

          true
        end

        def where_operation
          initial_relation
            .where(
              arel_column.send(
                arel_operator,
                arel_value
              )
            )
        end

        def merge_operation
          initial_relation
            .merge(
              attribute_model.public_send(
                @attribute_set_instruction.attribute,
                @attribute_set_instruction.value
              )
            )
        end

        def initial_relation
          return @set if @attribute_set_instruction.associations_array.empty?

          @set.eager_load(@attribute_set_instruction.associations_hash)
        end
      end
    end
  end
end
