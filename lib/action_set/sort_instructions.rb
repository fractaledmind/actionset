# frozen_string_literal: true

module ActionSet
  class SortInstructions
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

      instructions_hash.transform_values { |v| v.remove('ending') }
    end

    private

    def form_friendly_complex_params?
      @params.key?(:'0')
    end

    def form_friendly_simple_params?
      @params.key?(:attribute) &&
        @params.key?(:direction)
    end

    def form_friendly_complex_params_to_hash
      ordered_instructions = @params.sort_by(&:first)
      array_of_instructions = ordered_instructions.map { |_, h| [h[:attribute], h[:direction]] }
      Hash[array_of_instructions]
    end

    def form_friendly_simple_params_to_hash
      { @params[:attribute] => @params[:direction] }
    end
  end
end
