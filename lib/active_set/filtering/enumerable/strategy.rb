# frozen_string_literal: true

require_relative './set_instruction'
require 'active_support/core_ext/module/delegation'

class ActiveSet
  module Filtering
    module Enumerable
      class Strategy
        delegate :attribute_instance,
                 :attribute_class,
                 :instruction_value,
                 :attribute_value_for,
                 :operator,
                 :attribute,
                 :set_item,
                 :resource_for,
                 to: :@set_instruction

        def initialize(set, attribute_instruction)
          @set = set
          @attribute_instruction = attribute_instruction
          @set_instruction = SetInstruction.new(attribute_instruction, set)
        end

        def execute
          return false unless @set.respond_to? :select

          if execute_filter_operation?
            set = filter_operation
          elsif execute_intersect_operation?
            begin
              set = intersect_operation
            rescue TypeError # thrown if intersecting with a non-Array
              return false
            end
          else
            return false
          end

          set
        end

        private

        def execute_filter_operation?
          return false unless attribute_instance
          return false unless attribute_instance.respond_to?(attribute)
          return false if attribute_instance.method(attribute).arity.positive?

          true
        end

        def execute_intersect_operation?
          return false unless attribute_class
          return false unless attribute_class.respond_to?(attribute)
          return false if attribute_class.method(attribute).arity.zero?

          true
        end

        def filter_operation
          @set.select do |item|
            @set_instruction.item_matches_query?(item)
          end
        end

        def intersect_operation
          @set & other_set
        end

        def other_set
          other_set = attribute_class.public_send(
            attribute,
            instruction_value
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
      end
    end
  end
end
