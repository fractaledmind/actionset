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

    def case_insensitive?
      return false unless options

      options.include? :i
    end

    def attribute
      return @attribute if defined? @attribute

      attribute = @keypath.last
      attribute = attribute&.sub(operator_regex, '')
      attribute = attribute&.sub(options_regex, '')
      @attribute = attribute
    end

    def operator
      return @operator if defined? @operator

      attribute_instruction = @keypath.last
      @operator = attribute_instruction[operator_regex, 1]&.to_sym
    end

    def options
      return @options if defined? @options

      @options = @keypath.last[options_regex, 1]&.split('')&.map(&:to_sym)
    end

    def associations_array
      return @associations_array if defined? @associations_array
      return [] unless @keypath.any?

      @associations_array = @keypath.slice(0, @keypath.length - 1)
    end

    def associations_hash
      return @associations_hash if defined? @associations_hash
      return {} unless @keypath.any?

      @associations_hash = associations_array.reverse.reduce({}) do |hash, association|
        { association => hash }
      end
    end

    def value_for(item:)
      @values_for ||= Hash.new do |h, key|
        h[key] = resource_for(item: key).public_send(attribute)
      end

      @values_for[item]
    rescue StandardError
      # :nocov:
      nil
      # :nocov:
    end

    def resource_for(item:)
      @resources_for ||= Hash.new do |h, key|
        h[key] = associations_array.reduce(key) do |resource, association|
          break nil unless resource.respond_to? association

          resource.public_send(association)
        end
      end

      @resources_for[item]
    rescue StandardError
      # :nocov:
      nil
      # :nocov:
    end

    private

    def operator_regex
      /\((.*?)\)/
    end

    def options_regex
      %r{\/(.*?)\/}
    end
  end
end
