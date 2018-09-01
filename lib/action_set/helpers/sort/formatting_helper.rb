# frozen_string_literal: true

module Sort
  module FormattingHelper
    def ascending_str(format)
      return 'asc' if format.to_s == 'short'

      'ascending'
    end

    def descending_str(format)
      return 'desc' if format.to_s == 'short'

      'descending'
    end
  end
end
