# frozen_string_literal: true

require_relative '../attribute_instruction'
require_relative './enumerable_strategy'
require_relative './active_record_strategy'

class ActiveSet
  module Sorting
    class Operation
      def initialize(set, instructions_hash)
        @set = set
        @instructions_hash = instructions_hash
      end

      def execute
        attribute_instructions = @instructions_hash
                                 .flatten_keys
                                 .map { |k, v| AttributeInstruction.new(k, v) }

        activerecord_strategy = ActiveRecordStrategy.new(@set, attribute_instructions)
        if activerecord_strategy.executable_instructions == attribute_instructions
          activerecord_sorted_set = activerecord_strategy.execute
        end

        return activerecord_sorted_set if attribute_instructions.all?(&:processed?)

        EnumerableStrategy.new(@set, attribute_instructions).execute
      end

      def operation_instructions
        @instructions_hash.symbolize_keys
      end
    end
  end
end
