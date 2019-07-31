# frozen_string_literal: true

require_relative '../../active_record_set_instruction'
require_relative './operators'
require_relative './query_value'
require_relative './query_column'

class ActiveSet
  module Filtering
    module ActiveRecord
      class SetInstruction < ActiveRecordSetInstruction
        include QueryValue
        include QueryColumn

        def arel_operator
          operator_hash.fetch(:operator, :eq)
        end

        private

        def operator_hash
          instruction_operator = @attribute_instruction.operator

          Operators.get(instruction_operator)
        end
      end
    end
  end
end
