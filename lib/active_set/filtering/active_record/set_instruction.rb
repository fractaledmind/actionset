# frozen_string_literal: true

require_relative '../../active_record_set_instruction'
require_relative './operators'

class ActiveSet
  module Filtering
    module ActiveRecord
      class SetInstruction < ActiveRecordSetInstruction
        def arel_operator
          instruction_operator = @attribute_instruction.operator
          return :eq unless instruction_operator

          operator_hash = Operators.get(instruction_operator)
          operator_hash&.dig(:operator)
        end
      end
    end
  end
end
