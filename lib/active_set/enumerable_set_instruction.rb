# frozen_string_literal: true

class ActiveSet
  class EnumerableSetInstruction < SimpleDelegator
    def initialize(attribute_instruction, set)
      @attribute_instruction = attribute_instruction
      @set = set
      super(@attribute_instruction)
    end

    def attribute_value_for(item)
      item_value = @attribute_instruction
                    .value_for(item: item)
      item_value = item_value.downcase if case_insensitive_operation_for?(item_value)
      item_value
    end

    def attribute_value
      _attribute_value = @attribute_instruction.value
      _attribute_value = _attribute_value.downcase if case_insensitive_operation_for?(_attribute_value)
      _attribute_value
    end

    def case_insensitive_operation_for?(value)
      return false unless @attribute_instruction.case_insensitive?

      value.is_a?(String) || value.is_a?(Symbol)
    end

    def attribute_instance
      set_item = @set.find(&:present?)
      return set_item if @attribute_instruction.associations_array.empty?
      return @attribute_model if defined? @attribute_model

      @attribute_model = @attribute_instruction
                         .associations_array
                         .reduce(set_item) do |obj, assoc|
        obj.public_send(assoc)
      end
    end

    def attribute_class
      attribute_instance&.class
    end
  end
end
