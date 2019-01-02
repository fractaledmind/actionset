# frozen_string_literal: true

require_relative './enumerable_strategy'
require_relative './active_record_strategy'

class ActiveSet
  module Paginating
    class Operation
      def initialize(set, instructions_hash)
        @set = set
        @instructions_hash = instructions_hash
      end

      def execute
        [ActiveRecordStrategy, EnumerableStrategy].each do |strategy|
          maybe_set_or_false = strategy.new(@set, operation_instructions).execute
          break(maybe_set_or_false) if maybe_set_or_false
        end
      end

      def operation_instructions
        @instructions_hash.symbolize_keys.tap do |h|
          h[:page] = page_operation_instruction(h[:page])
          h[:size] = size_operation_instruction(h[:size])
          h[:count] = count_operation_instruction(@set)
        end
      end

      private

      def page_operation_instruction(initial)
        return 1 unless initial
        return 1 if initial.to_i <= 0

        initial.to_i
      end

      def size_operation_instruction(initial)
        return 25 unless initial
        return 25 if initial.to_i <= 0

        initial.to_i
      end

      def count_operation_instruction(set)
        # https://work.stevegrossi.com/2015/04/25/how-to-count-with-activerecord/
        maybe_integer_or_hash = set.size
        return maybe_integer_or_hash.count if maybe_integer_or_hash.is_a?(Hash)

        maybe_integer_or_hash
      end
    end
  end
end
