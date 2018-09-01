# frozen_string_literal: true

module Pagination
  module CurrentPageForHelper
    def pagination_current_page_for(set)
      set.instructions.dig(:paginate, :page)
    end
  end
end
