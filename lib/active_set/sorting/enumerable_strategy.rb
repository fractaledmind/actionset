# frozen_string_literal: true

require_relative '../../helpers/transform_to_sortable_numeric'
require_relative '../enumerable_set_instruction'

class ActiveSet
  module Sorting
    class EnumerableStrategy
      def initialize(set, attribute_instructions)
        @set = set
        @attribute_instructions = attribute_instructions
        @set_instructions = attribute_instructions.map do |attribute_instruction|
          EnumerableSetInstruction.new(attribute_instruction, set)
        end
      end

      def execute
        # http://brandon.dimcheff.com/2009/11/18/rubys-sort-vs-sort-by/
        @set.sort_by do |item|
          @set_instructions.map do |set_instruction|
            value_for_comparison = sortable_numeric_for(set_instruction, item)
            direction_multiplier = direction_multiplier(set_instruction.value)

            # Force null values to be sorted as if larger than any non-null value
            # ASC => [-2, -1, 1, 2, nil]
            # DESC => [nil, 2, 1, -1, -2]
            if value_for_comparison.nil?
              [direction_multiplier, 0]
            else
              [0, value_for_comparison * direction_multiplier]
            end
          end
        end
      end

      def sortable_numeric_for(set_instruction, item)
        value = set_instruction.attribute_value_for(item)

        transform_to_sortable_numeric(value)
      end

      def direction_multiplier(direction)
        return -1 if direction.to_s.downcase.start_with? 'desc'

        1
      end
    end
  end
end
