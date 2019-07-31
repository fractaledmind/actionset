# frozen_string_literal: true

require 'active_support/core_ext/array/wrap'
require_relative '../../enumerable_set_instruction'
require_relative './operators'

class ActiveSet
  module Filtering
    module Enumerable
      class SetInstruction < EnumerableSetInstruction
        def item_matches_query?(item)
          return query_result_for(item, query_attribute_for(instruction_value)) unless operator_hash.key?(:reducer)

          Array.wrap(instruction_value).public_send(operator_hash[:reducer]) do |value|
            query_result_for(item, query_attribute_for(value))
          end
        end

        def set_item
          return @set_item if defined? @set_item

          @set_item = @set.find(&:present?)
        end

        def attribute_instance
          return set_item if @attribute_instruction.associations_array.empty?
          return @attribute_model if defined? @attribute_model

          @attribute_model = @attribute_instruction
                             .associations_array
                             .reduce(set_item) do |obj, assoc|
            obj.public_send(assoc)
          end
        end

        def attribute_class
          attribute_instance&.class
        end

        private

        def query_result_for(item, value)
          result = if operator_method == :cover? && value.is_a?(Range)
                     value
                       .public_send(
                         operator_method,
                         object_attribute_for(item)
                       )
                   else
                     object_attribute_for(item)
                       .public_send(
                         operator_method,
                         value
                       )
                   end

          return result unless operator_hash.key?(:result_transformer)

          operator_hash[:result_transformer].call(result)
        end

        def object_attribute_for(item)
          attribute = guarantee_attribute_type(attribute_value_for(item))
          return attribute unless operator_hash.key?(:object_attribute_transformer)

          operator_hash[:object_attribute_transformer].call(attribute)
        end

        def query_attribute_for(value)
          attribute = guarantee_attribute_type(value)
          return attribute unless operator_hash.key?(:query_attribute_transformer)

          operator_hash[:query_attribute_transformer].call(attribute)
        end

        def operator_method
          operator_hash.dig(:operator) || :'=='
        end

        def operator_hash
          instruction_operator = @attribute_instruction.operator

          Operators.get(instruction_operator)
        end

        def guarantee_attribute_type(attribute)
          # Booleans don't respond to many operator methods,
          # so we cast them to integers
          return 1 if attribute == true
          return 0 if attribute == false
          return attribute.map { |a| guarantee_attribute_type(a) } if attribute.respond_to?(:each)

          attribute
        end
      end
    end
  end
end
