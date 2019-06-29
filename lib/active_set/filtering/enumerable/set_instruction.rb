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

        def other_set
          other_set = attribute_class.public_send(
                        attribute,
                        attribute_value
                      )
          if attribute_class != set_item.class
            other_set = begin
                        @set.select { |item| resource_for(item: item)&.presence_in other_set }
                      rescue ArgumentError # thrown if other_set is doesn't respond to #include?, like when nil
                        nil
                      end
          end

          other_set
        end

        private

        def object_attribute_for(item)
          attribute = guarantee_attribute_type(attribute_value_for(item))
          return attribute unless operator_hash.key?(:object_attribute_transformer)

          operator_hash[:object_attribute_transformer].call(attribute)
        end

        def query_attribute
          attribute = guarantee_attribute_type(attribute_value)
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
