# frozen_string_literal: true

require_relative './first_page_link_for_helper'
require_relative './prev_page_link_for_helper'
require_relative './current_page_description_for_helper'
require_relative './next_page_link_for_helper'
require_relative './last_page_link_for_helper'

module Pagination
  module LinksForHelper
    include Pagination::FirstPageLinkForHelper
    include Pagination::PrevPageLinkForHelper
    include Pagination::CurrentPageDescriptionForHelper
    include Pagination::NextPageLinkForHelper
    include Pagination::LastPageLinkForHelper

    def pagination_links_for(set, **attributes)
      content_tag(:nav,
                  **attributes.merge(
                    class: 'pagination',
                    'aria-label': 'Page navigation'
                  )) do
        safe_join([
                    pagination_first_page_link_for(set),
                    pagination_prev_page_link_for(set),
                    pagination_current_page_description_for(set),
                    pagination_next_page_link_for(set),
                    pagination_last_page_link_for(set)
                  ])
      end
    end
  end
end
