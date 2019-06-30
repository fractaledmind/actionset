# frozen_string_literal: true

module ActionSet
  class AttributeValue
    attr_reader :raw

    def initialize(value)
      @raw = value
    end

    def cast(to:)
      adapters.reduce(nil) do |_, adapter|
        mayble_value_or_nil = adapter.new(@raw, to).process
        next nil if mayble_value_or_nil.nil?

        return mayble_value_or_nil
      end

      @raw
    end

    private

    def adapters
      [ActiveModelAdapter, PlainRubyAdapter, BooleanAdapter, TimeWithZoneAdapter]
    end

    class PlainRubyAdapter
      def initialize(raw, target)
        @raw = raw
        @target = target
      end

      def process
        return @raw if @raw.is_a? @target

        possible_values.find { |v| v.is_a? @target }
      end

      private

      def possible_values
        possible_typecasters.map { |m| typecast(m) }
                            .compact
      end

      def possible_typecasters
        @possible_typecasters ||= String.instance_methods
                                        .map(&:to_s)
                                        .select { |m| m.start_with? 'to_' }
                                        .reject { |m| %w[to_v8 to_onum].include? m }
      end

      def typecast(method_name)
        @raw.send(method_name)
      rescue StandardError
        nil
      end
    end

    class ActiveModelAdapter
      begin
        require 'active_model/type'
      rescue LoadError
        # :nocov:
        require 'active_record/type'
        # :nocov:
      end

      def initialize(raw, target)
        @raw = raw
        @target = target
      end

      def process
        return @raw if @raw.is_a? @target

        possible_values.find { |v| v.is_a? @target }
      end

      private

      def possible_values
        possible_typecasters.map { |m| typecast(m, @raw) }
      end

      def possible_typecasters
        @possible_typecasters ||= type_class.constants
                                            .map(&:to_s)
                                            .select { |t| can_typecast?(t) }
                                            .reject { |t| t == 'Time' }
                                            .map { |t| init_typecaster(t) }
                                            .compact
      end

      def typecast(to_type, value)
        return to_type.type_cast(value) if to_type.respond_to? :type_cast

        to_type.cast(value)
      end

      def can_typecast?(const_name)
        typecasting_class = type_class.const_get(const_name)
        typecasting_class.instance_methods.include?(:cast) ||
          typecasting_class.instance_methods.include?(:type_cast)
      end

      def init_typecaster(const_name)
        type_class.const_get(const_name).new
      rescue StandardError
        # :nocov:
        nil
        # :nocov:
      end

      def type_class
        ActiveModel::Type
      rescue NameError
        # :nocov:
        ActiveRecord::Type
        # :nocov:
      end
    end

    class BooleanAdapter
      def initialize(raw, target)
        @raw = raw
        @target = target
      end

      def process
        return if @raw.is_a? @target
        return unless @target.eql?(TrueClass) || @target.eql?(FalseClass)

        # ActiveModel::Type::Boolean is too expansive in its casting; will get false positives
        to_bool
      end

      private

      def to_bool
        return @raw if @raw.is_a?(TrueClass) || @raw.is_a?(FalseClass)
        return true if %w[true yes 1 t].include? @raw.to_s.downcase
        return false if %w[false no 0 f].include? @raw.to_s.downcase

        nil
      end
    end

    class TimeWithZoneAdapter
      def initialize(raw, target)
        @raw = raw
        @target = target
      end

      def process
        return if @raw.is_a? @target
        return unless @target.eql?(ActiveSupport::TimeWithZone)

        time_value = ActiveModelAdapter.new(@raw, Time).process

        return unless time_value.is_a?(Time)
        return time_value unless time_value.respond_to?(:in_time_zone)

        time_value.in_time_zone
      end
    end
  end
end
