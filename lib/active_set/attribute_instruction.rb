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

      options.include? 'i'
    end

    def predicate?
      return false unless options

      options.include? 'p'
    end

    def attribute
      attribute = @keypath.last
      attribute = attribute.sub(operator_regex, '') if attribute&.match operator_regex
      attribute = attribute.sub(options_regex, '') if attribute&.match options_regex

      attribute
    end

    def operator
      return @value if predicate?

      @keypath.last[operator_regex, 1]
    end

    def options
      @keypath.last[options_regex, 1]&.split('')
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
      %r{\((.*?)\)}
    end

    def options_regex
      %r{\/(.*?)\/}
    end
  end
end
