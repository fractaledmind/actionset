# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './total_pages_for_helper'
require_relative './path_for_helper'

module Pagination
  module NextPageLinkForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::TotalPagesForHelper
    include Pagination::PathForHelper

    def pagination_next_page_link_for(set)
      current_page = pagination_current_page_for(set)
      total_pages = pagination_total_pages_for(set)

      if current_page != total_pages && current_page <= total_pages
        link_to('Next ›', pagination_path_for(current_page + 1), rel: 'next', class: 'page-link page-next')
      else
        content_tag(:span, 'Next ›', class: 'page-link page-next disabled')
      end
    end
  end
end
