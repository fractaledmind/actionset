# frozen_string_literal: true

require_relative '../../active_record_set_instruction'

class ActiveSet
  module Filtering
    module ActiveRecord
      class SetInstruction < ActiveRecordSetInstruction
        def arel_value
          return @arel_value if defined? @arel_value

          arel_value = @attribute_instruction.value
          arel_value = arel_value.downcase if case_insensitive_operation?

          @arel_value = arel_value
        end

        def arel_operator
          return @arel_operator if defined? @arel_operator

          @arel_operator = @attribute_instruction.operator(default: :eq)
        end
      end
    end
  end
end
