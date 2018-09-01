# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './total_pages_for_helper'
require_relative './path_for_helper'

module Pagination
  module LastPageLinkForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::TotalPagesForHelper
    include Pagination::PathForHelper

    def pagination_last_page_link_for(set)
      current_page = pagination_current_page_for(set)
      total_pages = pagination_total_pages_for(set)

      if current_page != total_pages && current_page <= total_pages
        link_to('Last »',  pagination_path_for(total_pages), class: 'page-link page-last')
      else
        content_tag(:span, 'Last »', class: 'page-link page-last disabled')
      end
    end
  end
end
