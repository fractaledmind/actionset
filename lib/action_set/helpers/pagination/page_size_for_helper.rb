# frozen_string_literal: true

module Pagination
  module PageSizeForHelper
    def pagination_page_size_for(set)
      set.instructions.dig(:paginate, :size)
    end
  end
end
