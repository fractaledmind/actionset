# frozen_string_literal: true

require_relative './attribute_instruction'

class ActiveSet
  class ColumnInstruction
    def initialize(instructions_hash, item)
      @instructions_hash = instructions_hash.symbolize_keys
      @item = item
    end

    def key
      return @instructions_hash[:key] if @instructions_hash.key? :key

      return titleized_attribute_key unless attribute_instruction.attribute

      attribute_resource = attribute_instruction.resource_for(item: @item)
      return titleized_attribute_key unless attribute_resource&.class&.respond_to?(:human_attribute_name)

      attribute_resource.class.human_attribute_name(attribute_instruction.attribute)
    end

    def value
      return default unless @instructions_hash.key?(:value)
      return @instructions_hash[:value].call(@item) if @instructions_hash[:value]&.respond_to? :call

      attribute_instruction.value_for(item: @item)
    end

    private

    def attribute_instruction
      AttributeInstruction.new(@instructions_hash[:value], nil)
    end

    def default
      return @instructions_hash[:default] if @instructions_hash.key? :default

      '—'
    end

    def titleized_attribute_key
      attribute_instruction.keypath.map(&:titleize).join(' ')
    end
  end
end
