# frozen_string_literal: true

require_relative './constants'

class ActiveSet
  module Filtering
    module ActiveRecord
      class AttributeSetInstruction < SimpleDelegator
        include Constants

        def initialize(attribute_instruction, set)
          @attribute_instruction = attribute_instruction
          @set = set
          super(@attribute_instruction)
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
          _arel_column = arel_table[@attribute_instruction.attribute]
          return _arel_column.lower if @attribute_instruction.case_insensitive?

          _arel_column
        end

        def arel_operator
          instruction_operator = @attribute_instruction.operator&.to_sym

          return :eq unless instruction_operator
          return OPERATORS[instruction_operator][:operator] if OPERATORS.key?(instruction_operator)

          instruction_operator
        end

        def arel_value
          return OPERATORS[@attribute_instruction.operator][:value_transformer].call(@attribute_instruction.value) if OPERATORS.key?(@attribute_instruction.operator) && OPERATORS[@attribute_instruction.operator].key?(:value_transformer)
          return @attribute_instruction.value unless @attribute_instruction.case_insensitive?
          return @attribute_instruction.value.downcase if @attribute_instruction.value.respond_to?(:downcase)
          return @attribute_instruction.value unless @attribute_instruction.value.is_a?(Array)

          @attribute_instruction.value.map do |v|
            next(v) unless v.respond_to?(:downcase)

            v.downcase
          end
        end
      end
    end
  end
end
