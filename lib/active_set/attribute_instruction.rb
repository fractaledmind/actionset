# frozen_string_literal: true

class ActiveSet
  class AttributeInstruction
    attr_accessor :processed
    attr_reader :keypath, :value

    def initialize(keypath, value)
      # `keypath` can be an Array (e.g. [:parent, :child, :grandchild, :attribute])
      # or a String (e.g. 'parent.child.grandchild.attribute')
      @keypath = Array(keypath).map(&:to_s).flat_map { |x| x.split('.') }
      @value = value
      @processed = false
    end

    def processed?
      @processed
    end

    def attribute
      attribute = @keypath.last
      return attribute.sub(operator_regex, '') if attribute&.match operator_regex

      attribute
    end

    def operator(default: '==')
      attribute = @keypath.last
      return attribute[operator_regex, 1] if attribute&.match operator_regex

      default
    end

    def associations_array
      return [] unless @keypath.any?

      @keypath.slice(0, @keypath.length - 1)
    end

    def associations_hash
      return {} unless @keypath.any?

      associations_array.reverse.reduce({}) do |hash, association|
        { association => hash }
      end
    end

    def value_for(item:)
      resource_for(item: item).public_send(attribute)
    rescue StandardError
      # :nocov:
      nil
      # :nocov:
    end

    def resource_for(item:)
      associations_array.reduce(item) do |resource, association|
        return nil unless resource.respond_to? association

        resource.public_send(association)
      end
    rescue StandardError
      # :nocov:
      nil
      # :nocov:
    end

    private

    def operator_regex
      /\((.*?)\)/
    end
  end
end
