# frozen_string_literal: true

class ActiveSet
  module Sorting
    class ActiveRecordStrategy
      def initialize(set, attribute_instructions)
        @set = set
        @attribute_instructions = attribute_instructions
      end

      def execute
        return false unless @set.respond_to? :to_sql

        executable_instructions.reduce(set_with_eager_loaded_associations) do |set, attribute_instruction|
          statement = set.merge(order_operation_for(attribute_instruction))

          return false if throws?(ActiveRecord::StatementInvalid) { statement.load }

          attribute_instruction.processed = true
          statement
        end
      end

      def executable_instructions
        return {} unless @set.respond_to? :to_sql

        @attribute_instructions.select do |attribute_instruction|
          attribute_model = attribute_model_for(attribute_instruction)
          next false unless attribute_model
          next false unless attribute_model.respond_to?(:attribute_names)
          next false unless attribute_model.attribute_names.include?(attribute_instruction.attribute)

          true
        end
      end

      private

      def set_with_eager_loaded_associations
        associations_hash = @attribute_instructions.reduce({}) { |h, i| h.merge(i.associations_hash) }
        @set.eager_load(associations_hash)
      end

      # https://stackoverflow.com/a/44912964/2884386
      # Force null values to be sorted as if larger than any non-null value
      # ASC => [-2, -1, 1, 2, nil]
      # DESC => [nil, 2, 1, -1, -2]
      def order_operation_for(attribute_instruction)
        attribute_model = attribute_model_for(attribute_instruction)

        arel_column = Arel::Table.new(attribute_model.table_name)[attribute_instruction.attribute]
        arel_column = case_insensitive?(attribute_instruction) ? arel_column.lower : arel_column
        arel_direction = direction_operator(attribute_instruction.value)
        nil_sorter = arel_column.send(arel_direction == :asc ? :eq : :not_eq, nil)

        attribute_model.order(nil_sorter).order(arel_column.send(arel_direction))
      end

      def attribute_model_for(attribute_instruction)
        return @set.klass if attribute_instruction.associations_array.empty?

        attribute_instruction
          .associations_array
          .reduce(@set) do |obj, assoc|
            obj.reflections[assoc.to_s]&.klass
          end
      end

      def case_insensitive?(attribute_instruction)
        attribute_instruction.operator.to_s.casecmp('i').zero?
      end

      def direction_operator(direction)
        return :desc if direction.to_s.downcase.start_with? 'desc'

        :asc
      end
    end
  end
end
