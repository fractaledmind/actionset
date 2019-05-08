# frozen_string_literal: true

class ActiveSet
  class EnumerableSetInstruction < SimpleDelegator
    def initialize(attribute_instruction, set)
      @attribute_instruction = attribute_instruction
      @set = set
      super(@attribute_instruction)
    end

    def attribute_value_for(item)
      @attribute_instruction
        .value_for(item: item)
    end

    def attribute_value
      @attribute_instruction.value
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
