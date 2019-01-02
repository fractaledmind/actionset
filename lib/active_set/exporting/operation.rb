# frozen_string_literal: true

require_relative './csv_strategy'

class ActiveSet
  module Exporting
    class Operation
      def initialize(set, instructions_hash)
        @set = set
        @instructions_hash = instructions_hash
      end

      def execute
        strategy_for(format: operation_instructions[:format].to_s.downcase)
          .new(@set, operation_instructions[:columns])
          .execute
      end

      def operation_instructions
        @instructions_hash.symbolize_keys
      end

      private

      def strategy_for(format:)
        return CSVStrategy if format == 'csv'
      end
    end
  end
end
