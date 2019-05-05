# frozen_string_literal: true

class ActiveSet
  module Filtering
    class ActiveRecordStrategy
      def initialize(set, attribute_instruction)
        @set = set
        @attribute_instruction = attribute_instruction
      end

      def execute
        return false unless @set.respond_to? :to_sql

        if execute_where_operation?
          statement = where_operation
        elsif execute_merge_operation?
          begin
            statement = merge_operation
          rescue ArgumentError # thrown if merging a non-ActiveRecord::Relation
            return false
          end
        else
          return false
        end

        statement
      end

      private

      def execute_where_operation?
        return false unless attribute_model
        return false unless attribute_model.respond_to?(:attribute_names)
        return false unless attribute_model.attribute_names.include?(@attribute_instruction.attribute)

        true
      end

      def execute_merge_operation?
        return false unless attribute_model
        return false unless attribute_model.respond_to?(@attribute_instruction.attribute)
        return false if attribute_model.method(@attribute_instruction.attribute).arity.zero?

        true
      end

      def where_operation
        initial_relation
          .where(
            arel_column.send(
              @attribute_instruction.operator(default: 'eq'),
              @attribute_instruction.value
            )
          )
      end

      def merge_operation
        initial_relation
          .merge(
            attribute_model.public_send(
              @attribute_instruction.attribute,
              @attribute_instruction.value
            )
          )
      end

      def initial_relation
        return @set if @attribute_instruction.associations_array.empty?

        @set.eager_load(@attribute_instruction.associations_hash)
      end

      def arel_column
        attribute_type = attribute_model.columns_hash[@attribute_instruction.attribute].type

        # This is to work around an bug in ActiveRecord,
        # where BINARY fields aren't found properly when using the `arel_table` class method
        # to build an ARel::Node
        if attribute_type == :binary
          Arel::Table.new(attribute_model.table_name)[@attribute_instruction.attribute]
        else
          attribute_model.arel_table[@attribute_instruction.attribute]
        end
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
end
