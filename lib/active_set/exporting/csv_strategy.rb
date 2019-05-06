# frozen_string_literal: true

require_relative '../column_instruction'

class ActiveSet
  module Exporting
    class CSVStrategy
      require 'csv'

      def initialize(set, column_instructions)
        @set = set
        @column_instructions = column_instructions
      end

      def execute
        ::CSV.generate do |output|
          output << column_keys_for(item: @set.first)
          @set.each do |item|
            output << column_values_for(item: item)
          end
        end
      end

      private

      def column_keys_for(item:)
        columns.map do |column|
          ColumnInstruction.new(column, item).key
        end
      end

      def column_values_for(item:)
        columns.map do |column|
          ColumnInstruction.new(column, item).value
        end
      end

      def columns
        @column_instructions.compact
      end
    end
  end
end
