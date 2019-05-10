# frozen_string_literal: true

require_relative './current_page_for_helper'
require_relative './total_pages_for_helper'

module Pagination
  module CurrentPageDescriptionForHelper
    include Pagination::CurrentPageForHelper
    include Pagination::TotalPagesForHelper

    def pagination_current_page_description_for(set)
      description = [
        'Page',
        "<strong>#{pagination_current_page_for(set)}</strong>",
        'of',
        "<strong>#{pagination_total_pages_for(set)}</strong>"
      ].join('&nbsp;').html_safe

      content_tag(:span,
                  description,
                  class: 'page-current')
    end
  end
end
