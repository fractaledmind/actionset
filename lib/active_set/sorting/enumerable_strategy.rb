# frozen_string_literal: true

require_relative '../../helpers/transform_to_sortable_numeric'

class ActiveSet
  module Sorting
    class EnumerableStrategy
      def initialize(set, attribute_instructions)
        @set = set
        @attribute_instructions = attribute_instructions
      end

      def execute
        # http://brandon.dimcheff.com/2009/11/18/rubys-sort-vs-sort-by/
        @set.sort_by do |item|
          @attribute_instructions.map do |instruction|
            value_for_comparison = sortable_numeric_for(instruction, item)
            direction_multiplier = direction_multiplier(instruction.value)

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

      def sortable_numeric_for(instruction, item)
        value = instruction.value_for(item: item)
        if value.is_a?(String) || value.is_a?(Symbol)
          value = if case_insensitive?(instruction, value)
                    value.to_s.downcase
                  else
                    value.to_s
                  end
        end

        transform_to_sortable_numeric(value)
      end

      def case_insensitive?(instruction, _value)
        instruction.operator.to_s.casecmp('i').zero?
      end

      def direction_multiplier(direction)
        return -1 if direction.to_s.downcase.start_with? 'desc'

        1
      end
    end
  end
end
