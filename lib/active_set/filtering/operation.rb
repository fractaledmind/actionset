# frozen_string_literal: true

require_relative '../attribute_instruction'
require_relative './enumerable_strategy'
require_relative './active_record/strategy'

class ActiveSet
  module Filtering
    class Operation
      def initialize(set, instructions_hash)
        @set = set
        @instructions_hash = instructions_hash
      end

      def execute
        activerecord_filtered_set = attribute_instructions.reduce(@set) do |set, attribute_instruction|
          process_attribute_instruction_with_strategy(
            set,
            attribute_instruction,
            ActiveRecord::Strategy
          )
        end

        return activerecord_filtered_set if attribute_instructions.all?(&:processed?)

p ['@@@', activerecord_filtered_set.to_sql]

        attribute_instructions.reject(&:processed?).reduce(activerecord_filtered_set) do |set, attribute_instruction|
          process_attribute_instruction_with_strategy(
            set,
            attribute_instruction,
            EnumerableStrategy
          )
        end
      end

      def operation_instructions
        @instructions_hash.symbolize_keys
      end

      private

      def attribute_instructions
        @attribute_instructions ||= @instructions_hash
                                      .flatten_keys
                                      .map { |k, v| AttributeInstruction.new(k, v) }
      end

      def process_attribute_instruction_with_strategy(set, attribute_instruction, strategy_class)
        maybe_set_or_false = strategy_class.new(set, attribute_instruction).execute
        return set unless maybe_set_or_false

        attribute_instruction.processed = true
        maybe_set_or_false
      end
    end
  end
end
