# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './page_size_for_helper'

module Pagination
  module RecordFirstForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::PageSizeForHelper

    def pagination_record_first_for(set)
      current_page = pagination_current_page_for(set)
      page_size = pagination_page_size_for(set)

      return 1 if current_page == 1

      ((current_page - 1) * page_size) + 1
    end
  end
end
