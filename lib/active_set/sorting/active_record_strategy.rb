# frozen_string_literal: true

require_relative '../active_record_set_instruction'

class ActiveSet
  module Sorting
    class ActiveRecordStrategy
      def initialize(set, attribute_instructions)
        @set = set
        @attribute_instructions = attribute_instructions
      end

      def execute
        return false unless @set.respond_to? :to_sql

        executable_instructions.reduce(@set) do |set, attribute_instruction|
          statement = set.merge(initial_relation_for(attribute_instruction))
          statement = statement.merge(order_operation_for(attribute_instruction))

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

      def order_operation_for(attribute_instruction)
        attribute_model = attribute_model_for(attribute_instruction)
        table_name = attribute_model.table_name
        column_name = arel_column_name_for(attribute_instruction)
        direction = direction_operator(attribute_instruction.value)
        arel_column = arel_column_for(attribute_instruction)
        arel_type = arel_type_for(attribute_instruction)

        nil_sort_instruction = nil_sorter_for(arel_column,
                                              direction)
        col_sort_instruction = if adapter_type.presence_in(%i[mysql mysql2]) && arel_type.presence_in(%i[string text])
                                 Arel.sql("#{arel_column_to_sql(arel_column)} COLLATE utf8_bin #{direction.to_s.upcase}")
                               else
                                 arel_column.send(direction)
                               end

        attribute_model.order(nil_sort_instruction)
                       .order(col_sort_instruction)
      end

      # https://stackoverflow.com/a/44912964/2884386
      # When ActiveSet.configuration.on_asc_sort_nils_come == :last
      # null values to be sorted as if larger than any non-null value.
      # ASC => [-2, -1, 1, 2, nil]
      # DESC => [nil, 2, 1, -1, -2]
      # Otherwise sort nulls as if smaller than any non-null value.
      # ASC => [nil, -2, -1, 1, 2]
      # DESC => [2, 1, -1, -2, nil]
      def nil_sorter_for(arel_column, direction)
        null_as_zero = 'THEN 0 ELSE 1 END'
        null_as_one = 'THEN 1 ELSE 0 END'
        then_statement = case [ActiveSet.configuration.on_asc_sort_nils_come, direction]
                         when %i[last asc]
                           null_as_one
                         when %i[last desc]
                           null_as_zero
                         when %i[first asc]
                           null_as_zero
                         when %i[first desc]
                           null_as_one
                         else
                           null_as_one
                         end

        Arel.sql("CASE WHEN #{arel_column_to_sql(arel_column)} IS NULL #{then_statement}")
      end

      def direction_operator(direction)
        return :desc if direction.to_s.downcase.start_with? 'desc'

        :asc
      end

      def attribute_model_for(attribute_instruction)
        return @set.klass if attribute_instruction.associations_array.empty?

        attribute_instruction.associations_array
                             .reduce(@set) do |object, association|
          object.reflections[association.to_s]&.klass
        end
      end

      def initial_relation_for(attribute_instruction)
        if attribute_instruction.associations_array.empty?
          @set
        else
          @set.eager_load(attribute_instruction.associations_hash)
        end
      end

      def arel_table_for(attribute_instruction)
        attribute_model   =   attribute_model_for(attribute_instruction)
        arel_type         =   arel_type_for(attribute_instruction)

        # This is to work around an bug in ActiveRecord,
        # where BINARY fields aren't found properly when using
        # the `arel_table` class method to build an ARel::Node
        if arel_type == :binary
          Arel::Table.new(attribute_model.table_name)
        else
          attribute_model.arel_table
        end
      end

      def arel_type_for(attribute_instruction)
        attribute_model   =   attribute_model_for(attribute_instruction)
        attribute         =   attribute_instruction.attribute

        attribute_model
          &.columns_hash[attribute]
          &.type
      end

      def arel_column_name_for(attribute_instruction)
        arel_table    =   arel_table_for(attribute_instruction)
        attribute     =   attribute_instruction.attribute
        arel_column   =   arel_table[attribute]

        arel_column.name
      end

      def arel_column_for(attribute_instruction)
        arel_table  =   arel_table_for(attribute_instruction)
        arel_type   =   arel_type_for(attribute_instruction)
        attribute   =   attribute_instruction.attribute
        is_case_insensitive_operation = begin
          attribute_instruction.case_insensitive? &&
            arel_type.presence_in(%i[string text])
        end

        arel_column = arel_table[attribute]
        arel_column = arel_column.lower if is_case_insensitive_operation
        arel_column
      end

      def adapter_type
        return @adapter_type if defined? @adapter_type

        @adapter_type = ActiveRecord::Base.connection
                                          .adapter_name
                                          .downcase
                                          .to_sym
      end

      def arel_column_to_sql(arel_column)
        # the ARel column can already be rendered as SQL (because it is wrapped in a LOWER function, for example)
        if arel_column.respond_to?(:to_sql)
          arel_column.to_sql
        else
          arel_column.eq(nil).to_sql.remove(' IS NULL')
        end
      end
    end
  end
end
