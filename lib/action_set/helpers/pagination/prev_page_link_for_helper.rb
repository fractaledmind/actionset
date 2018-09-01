# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './total_pages_for_helper'
require_relative './path_for_helper'

module Pagination
  module PrevPageLinkForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::TotalPagesForHelper
    include Pagination::PathForHelper

    def pagination_prev_page_link_for(set)
      current_page = pagination_current_page_for(set)

      if current_page > 1 && current_page <= pagination_total_pages_for(set)
        link_to('‹ Prev', pagination_path_for(current_page - 1), rel: 'prev', class: 'page-link page-prev')
      else
        content_tag(:span, '‹ Prev', class: 'page-link page-prev disabled')
      end
    end
  end
end
