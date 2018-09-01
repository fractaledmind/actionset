# frozen_string_literal: true

require_relative '../params/current_helper'
require_relative './formatting_helper'

module Sort
  module CurrentDirectionForHelper
    include Params::CurrentHelper
    include Sort::FormattingHelper

    def current_sort_direction_for(attribute, format: :short)
      direction = current_params.dig(:sort, attribute).to_s.downcase

      return ascending_str(format) if direction.presence_in %w[asc ascending]
      return descending_str(format) if direction.presence_in %w[desc descending]

      direction
    end
  end
end
