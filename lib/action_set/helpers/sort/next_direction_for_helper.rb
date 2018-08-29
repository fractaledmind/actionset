# frozen_string_literal: true

# depends upon #current_sort_direction_for

module Sort
  module NextDirectionForHelper
    def next_sort_direction_for(attribute, format: :short)
      direction = current_sort_direction_for(attribute)

      return _ascending(format) unless direction
      return _ascending(format) unless direction.presence_in %w[asc desc ascending descending]
      return _ascending(format) if direction.presence_in %w[desc descending]
      return _descending(format) if direction.presence_in %w[asc ascending]
    end

    private

    def _ascending(format)
      return 'asc' if format.to_s == 'short'

      'ascending'
    end

    def _descending(format)
      return 'desc' if format.to_s == 'short'

      'descending'
    end
  end
end
