# frozen_string_literal: true

class ActiveSet
  class ActiveRecordSetInstruction < SimpleDelegator
    def initialize(attribute_instruction, set)
      @attribute_instruction = attribute_instruction
      @set = set
      super(@attribute_instruction)
    end

    def initial_relation
      return @initial_relation if defined? @initial_relation

      @initial_relation = if @attribute_instruction.associations_array.empty?
                            @set
                          else
                            @set.eager_load(@attribute_instruction.associations_hash)
                          end
    end

    def arel_column
      return @arel_column if defined? @arel_column

      arel_column = arel_table[@attribute_instruction.attribute]
      arel_column = arel_column.lower if case_insensitive_operation?

      @arel_column = arel_column
    end

    def arel_column_name
      arel_table[@attribute_instruction.attribute].name
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

    private

    def arel_type
      attribute_model
        &.columns_hash[@attribute_instruction.attribute]
        &.type
    end

    def case_insensitive_operation?
      @attribute_instruction.case_insensitive? && arel_type.presence_in(%i[string text])
    end
  end
end
