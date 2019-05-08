# frozen_string_literal: true

class ActiveSet
  class ActiveRecordSetInstruction < SimpleDelegator
    def initialize(attribute_instruction, set)
      @attribute_instruction = attribute_instruction
      @set = set
      super(@attribute_instruction)
    end

    def initial_relation
      return @set if @attribute_instruction.associations_array.empty?

      @set.eager_load(@attribute_instruction.associations_hash)
    end

    def arel_type
      attribute_model
        .columns_hash[@attribute_instruction.attribute]
        .type
    end

    def arel_table
      # This is to work around an bug in ActiveRecord,
      # where BINARY fields aren't found properly when using
      # the `arel_table` class method to build an ARel::Node
      if arel_type == :binary
        Arel::Table.new(attribute_model.table_name)
      else
        attribute_model.arel_table
      end
    end

    def arel_column
      arel_table[@attribute_instruction.attribute]
    end

    def arel_operator
      @attribute_instruction.operator(default: :eq)
    end

    def arel_value
      @attribute_instruction.value
    end

    def attribute_model
      return @set.klass if @attribute_instruction.associations_array.empty?
      return @attribute_model if defined? @attribute_model

      @attribute_model = @attribute_instruction
                         .associations_array
                         .reduce(@set) do |obj, assoc|
        obj.reflections[assoc.to_s]&.klass
      end
    end
  end
end
