# frozen_string_literal: true

module Sort
  module CurrentDirectionForHelper
    def current_sort_direction_for(attribute, format: :short)
      direction = current_params.dig(:sort, attribute).to_s.downcase

      return _ascending(format) if direction.presence_in %w[asc ascending]
      return _descending(format) if direction.presence_in %w[desc descending]

      direction
    end

    def current_params
      return params.to_unsafe_hash if params.respond_to? :to_unsafe_hash

      params
    end
  end
end
