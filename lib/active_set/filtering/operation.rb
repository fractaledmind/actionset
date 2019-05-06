# frozen_string_literal: true

require_relative '../attribute_instruction'
require_relative './enumerable_strategy'
require_relative './active_record_strategy'

class ActiveSet
  module Filtering
    class Operation
      def initialize(set, instructions_hash)
        @set = set
        @instructions_hash = instructions_hash
      end

      # rubocop:disable Metrics/MethodLength
      def execute
        attribute_instructions = @instructions_hash
                                 .flatten_keys
                                 .map { |k, v| AttributeInstruction.new(k, v) }

        activerecord_filtered_set = attribute_instructions.reduce(@set) do |set, attribute_instruction|
          maybe_set_or_false = ActiveRecordStrategy.new(set, attribute_instruction).execute
          next set unless maybe_set_or_false

          attribute_instruction.processed = true
          maybe_set_or_false
        end

        return activerecord_filtered_set if attribute_instructions.all?(&:processed?)

        attribute_instructions.reject(&:processed?).reduce(activerecord_filtered_set) do |set, attribute_instruction|
          maybe_set_or_false = EnumerableStrategy.new(set, attribute_instruction).execute
          next set unless maybe_set_or_false

          attribute_instruction.processed = true
          maybe_set_or_false
        end
      end
      # rubocop:enable Metrics/MethodLength

      def operation_instructions
        @instructions_hash.symbolize_keys
      end
    end
  end
end
