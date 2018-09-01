# frozen_string_literal: true

require_relative './current_direction_for_helper'
require_relative './formatting_helper'

module Sort
  module NextDirectionForHelper
    include Sort::CurrentDirectionForHelper
    include Sort::FormattingHelper

    def next_sort_direction_for(attribute, format: :short)
      direction = current_sort_direction_for(attribute)

      return ascending_str(format) unless direction.presence_in %w[asc desc ascending descending]
      return ascending_str(format) if direction.presence_in %w[desc descending]
      return descending_str(format) if direction.presence_in %w[asc ascending]

      ascending_str(format)
    end
  end
end
