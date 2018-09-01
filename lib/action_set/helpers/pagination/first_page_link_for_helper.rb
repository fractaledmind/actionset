# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './path_for_helper'

module Pagination
  module FirstPageLinkForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::PathForHelper

    def pagination_first_page_link_for(set)
      if pagination_current_page_for(set) > 1
        link_to('« First', pagination_path_for(1), class: 'page-link page-first')
      else
        content_tag(:span, '« First', class: 'page-link page-first disabled')
      end
    end
  end
end
