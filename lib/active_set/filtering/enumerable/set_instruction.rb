# frozen_string_literal: true

require_relative '../../enumerable_set_instruction'
require_relative './operators'

class ActiveSet
  module Filtering
    module Enumerable
      class SetInstruction < EnumerableSetInstruction
        def item_matches_query?(item)
          result = object_attribute_for(item)
            .public_send(
              operator_method,
              query_attribute
            )

          return result unless operator_hash.key?(:result_transformer)

          operator_hash[:result_transformer].call(result)
        end

        def object_attribute_for(item)
          attribute = guarantee_attribute_type(attribute_value_for(item))
          return attribute unless operator_hash.key?(:object_attribute_transformer)

          operator_hash[:object_attribute_transformer].call(attribute)
        end

        def query_attribute
          attribute = guarantee_attribute_type(instruction_value)
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
      end
    end
  end
end
