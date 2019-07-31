# frozen_string_literal: true

require_relative './record_size_for_helper'
require_relative './page_size_for_helper'

module Pagination
  module TotalPagesForHelper
    include Pagination::RecordSizeForHelper
    include Pagination::PageSizeForHelper

    def pagination_total_pages_for(set)
      total_set_size = pagination_record_size_for(set)
      return 1 if total_set_size.zero?

      (total_set_size.to_f / pagination_page_size_for(set)).ceil
    end
  end
end
