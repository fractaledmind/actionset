# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './record_size_for_helper'
require_relative './page_size_for_helper'
require_relative './total_pages_for_helper'

module Pagination
  module RecordLastForHelper
    include Pagination::RecordSizeForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::PageSizeForHelper
    include Pagination::TotalPagesForHelper

    def pagination_record_last_for(set)
      record_size = pagination_record_size_for(set)
      current_page = pagination_current_page_for(set)
      page_size = pagination_page_size_for(set)
      total_pages = pagination_total_pages_for(set)

      return record_size if current_page >= total_pages

      current_page * page_size
    end
  end
end
