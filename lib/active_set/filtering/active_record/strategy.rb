# frozen_string_literal: true

require_relative './set_instruction'
require 'active_support/core_ext/module/delegation'

class ActiveSet
  module Filtering
    module ActiveRecord
      class Strategy
        delegate :attribute_model,
                 :query_column,
                 :arel_operator,
                 :query_value,
                 :arel_type,
                 :initial_relation,
                 :attribute,
                 to: :@set_instruction

        def initialize(set, attribute_instruction)
          @set = set
          @attribute_instruction = attribute_instruction
          @set_instruction = SetInstruction.new(attribute_instruction, set)
        end

        def execute
          return false unless @set.respond_to? :to_sql

          if execute_filter_operation?
            statement = filter_operation
          elsif execute_intersect_operation?
            begin
              statement = intersect_operation
            rescue ArgumentError # thrown if merging a non-ActiveRecord::Relation
              return false
            end
          else
            return false
          end

          statement
        end

        private

        def execute_filter_operation?
          return false unless attribute_model
          return false unless attribute_model.respond_to?(:attribute_names)
          return false unless attribute_model.attribute_names.include?(attribute)

          true
        end

        def execute_intersect_operation?
          return false unless attribute_model
          return false unless attribute_model.respond_to?(attribute)
          return false if attribute_model.method(attribute).arity.zero?

          true
        end

        def filter_operation
          initial_relation
            .where(
              query_column.send(
                arel_operator,
                query_value
              )
            )
        end

        def intersect_operation
          # NOTE: If merging relations that contain duplicate column conditions,
          # the second condition will replace the first.
          # e.g. Thing.where(id: [1,2]).merge(Thing.where(id: [2,3]))
          # => [Thing<2>, Thing<3>] NOT [Thing<2>]
          initial_relation
            .merge(
              attribute_model.public_send(
                attribute,
                query_value
              )
            )
        end
      end
    end
  end
end
