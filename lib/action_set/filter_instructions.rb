# frozen_string_literal: true

require_relative './attribute_value'

module ActionSet
  class FilterInstructions
    def initialize(params, set, controller)
      @params = params
      @set = set
      @controller = controller
    end

    def get
      instructions_hash = if form_friendly_complex_params?
                            form_friendly_complex_params_to_hash
                          elsif form_friendly_simple_params?
                            form_friendly_simple_params_to_hash
                          else
                            @params
                          end
      flattened_instructions = flatten_keys_of(instructions_hash).reject { |_, v| v.try(:empty?) }
      flattened_instructions.each_with_object({}) do |(keypath, value), memo|
        memo[keypath] = if value.respond_to?(:map)
                          value.map { |v| AttributeValue.new(v).cast(to: klass_for_keypath(keypath, v, @set)) }
                        else
                          AttributeValue.new(value).cast(to: klass_for_keypath(keypath, value, @set))
                        end
      end
    end

    private

    def form_friendly_complex_params?
      @params.key?(:'0')
    end

    def form_friendly_simple_params?
      @params.key?(:attribute) &&
        @params.key?(:operator) &&
        @params.key?(:query)
    end

    def form_friendly_complex_params_to_hash
      ordered_instructions = @params.sort_by(&:first)
      array_of_instructions = ordered_instructions.map { |_, h| ["#{h[:attribute]}(#{h[:operator]})", h[:query]] }
      Hash[array_of_instructions]
    end

    def form_friendly_simple_params_to_hash
      { "#{@params[:attribute]}(#{@params[:operator]})" => @params[:query] }
    end

    def klass_for_keypath(keypath, value, set)
      if @controller.respond_to?(:filter_set_types, true)
        type_declarations = @controller.public_send(:filter_set_types)
        types = type_declarations['types'] || type_declarations[:types]
        klass = types[keypath.join('.')]
        return klass if klass
      end

      if set.is_a?(ActiveRecord::Relation) || set.view.is_a?(ActiveRecord::Relation)
        klass_type = set.model.columns_hash.fetch(keypath, nil)&.type
        return klass_type.class if klass_type
      end

      instruction = ActiveSet::AttributeInstruction.new(keypath, value)
      item_with_value = set.find { |i| !instruction.value_for(item: i).nil? }
      item_value = instruction.value_for(item: item_with_value)
      item_value.class
    end
  end
end
