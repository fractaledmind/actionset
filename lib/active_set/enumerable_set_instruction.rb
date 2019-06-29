# frozen_string_literal: true

class ActiveSet
  class EnumerableSetInstruction < SimpleDelegator
    def initialize(attribute_instruction, set)
      @attribute_instruction = attribute_instruction
      @set = set
      super(@attribute_instruction)
    end

    def attribute_value_for(item)
      @item_values ||= Hash.new do |h, key|
        item_value = @attribute_instruction.value_for(item: key)
        item_value = item_value.downcase if case_insensitive_operation_for?(item_value)
        h[key] = item_value
      end

      @item_values[item]
    end

    def instruction_value
      return @instruction_value if defined? @instruction_value

      instruction_value = @attribute_instruction.value
      instruction_value = instruction_value.downcase if case_insensitive_operation_for?(instruction_value)
      @instruction_value = instruction_value
    end

    def case_insensitive_operation_for?(value)
      return false unless @attribute_instruction.case_insensitive?

      value.is_a?(String) || value.is_a?(Symbol)
    end
  end
end
