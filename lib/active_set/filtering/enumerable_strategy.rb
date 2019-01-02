# frozen_string_literal: true

class ActiveSet
  module Filtering
    class EnumerableStrategy
      def initialize(set, attribute_instruction)
        @set = set
        @attribute_instruction = attribute_instruction
      end

      def execute
        return false unless @set.respond_to? :select

        @set.select do |item|
          next attribute_matches_for?(item) if can_match_attribute_for?(item)
          next class_method_matches_for?(item) if can_match_class_method_for?(item)

          next false
        end
      end

      private

      def can_match_attribute_for?(item)
        attribute_item = attribute_item_for(item)

        return false unless attribute_item
        return false unless attribute_item.respond_to?(@attribute_instruction.attribute)
        return false if attribute_item.method(@attribute_instruction.attribute).arity.positive?

        true
      end

      def can_match_class_method_for?(item)
        attribute_item = attribute_item_for(item)

        return false unless attribute_item
        return false unless attribute_item.class
        return false unless attribute_item.class.respond_to?(@attribute_instruction.attribute)
        return false if attribute_item.class.method(@attribute_instruction.attribute).arity.zero?

        true
      end

      def attribute_matches_for?(item)
        @attribute_instruction
          .value_for(item: item)
          .public_send(
            @attribute_instruction.operator,
            @attribute_instruction.value
          )
      end

      # rubocop:disable Metrics/MethodLength
      def class_method_matches_for?(item)
        maybe_item_or_collection_or_nil = attribute_item_for(item)
                                          .class
                                          .public_send(
                                            @attribute_instruction.attribute,
                                            @attribute_instruction.value
                                          )
        if maybe_item_or_collection_or_nil.nil?
          false
        elsif maybe_item_or_collection_or_nil.respond_to?(:each)
          maybe_item_or_collection_or_nil.include? attribute_item_for(item)
        else
          maybe_item_or_collection_or_nil.present?
        end
      end
      # rubocop:enable Metrics/MethodLength

      def attribute_item_for(item)
        @attribute_instruction
          .resource_for(item: item)
      end
    end
  end
end
