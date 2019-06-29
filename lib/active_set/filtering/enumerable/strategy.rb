# frozen_string_literal: true

require_relative './set_instruction'

class ActiveSet
  module Filtering
    module Enumerable
      class Strategy
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
          return false if not @set_instruction.attribute_instance
          return false if not @set_instruction.attribute_instance.respond_to?(@set_instruction.attribute)
          return false if @set_instruction.attribute_instance.method(@set_instruction.attribute).arity.positive?

          true
        end

        def execute_intersect_operation?
          return false if not @set_instruction.attribute_class
          return false if not @set_instruction.attribute_class.respond_to?(@set_instruction.attribute)
          return false if @set_instruction.attribute_class.method(@set_instruction.attribute).arity.zero?

          true
        end

        def filter_operation
          @set.select do |item|
            @set_instruction.item_matches_query?(item)
          end
        end

        def intersect_operation
          @set & @set_instruction.other_set
        end
      end
    end
  end
end
