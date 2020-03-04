# frozen_string_literal: true

require_relative './record_first_for_helper'
require_relative './record_last_for_helper'

module Pagination
  module RecordRangeForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::TotalPagesForHelper
    include Pagination::RecordFirstForHelper
    include Pagination::RecordLastForHelper

    def pagination_record_range_for(set)
      current_page = pagination_current_page_for(set)
      total_pages = pagination_total_pages_for(set)
      return 'None' if current_page > total_pages

      [
        pagination_record_first_for(set),
        '&ndash;',
        pagination_record_last_for(set)
      ].join('&nbsp;').html_safe
    end
  end
end
