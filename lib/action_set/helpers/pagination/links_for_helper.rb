module Pagination
  module LinksForHelper
    def pagination_links_for(set)
      content_tag(:nav, class: 'pagination', 'aria-label': 'Page navigation') do
        safe_join([
          link_to_first_page(set),
          link_to_prev_page(set),
          description_of_current_page(set),
          link_to_next_page(set),
          link_to_last_page(set)
        ])
      end
    end

    private

    def description_of_current_page(set)
      description = "Page&nbsp;<strong>#{current_page_for(set)}</strong>&nbsp;of&nbsp;<strong>#{total_pages_for(set)}</strong>".html_safe

      content_tag(:span,
                  description,
                  class: 'page-current')
    end

    def link_to_first_page(set)
      if current_page_for(set) > 1
        link_to('« First', paginate_path_for(1), class: 'page-link page-first')
      else
        content_tag(:span, '« First', class: 'page-link page-first disabled')
      end
    end

    def link_to_prev_page(set)
      current_page = current_page_for(set)

      if current_page > 1 && current_page <= total_pages_for(set)
        link_to('‹ Prev', paginate_path_for(current_page - 1), rel: 'prev', class: 'page-link page-prev')
      else
        content_tag(:span, '‹ Prev', class: 'page-link page-prev disabled')
      end
    end

    def link_to_last_page(set)
      current_page = current_page_for(set)
      total_pages = total_pages_for(set)

      if current_page != total_pages && current_page <= total_pages
        link_to('Last »',  paginate_path_for(total_pages), class: 'page-link page-last')
      else
        content_tag(:span, 'Last »', class: 'page-link page-last disabled')
      end
    end

    def link_to_next_page(set)
      current_page = current_page_for(set)
      total_pages = total_pages_for(set)

      if current_page != total_pages && current_page <= total_pages
        link_to('Next ›', paginate_path_for(current_page + 1), rel: 'next', class: 'page-link page-next')
      else
        content_tag(:span, 'Next ›', class: 'page-link page-next disabled')
      end
    end

    def total_pages_for(set)
      total_set_size = set.set.count

      (total_set_size.to_f / page_size_for(set)).ceil
    end

    def current_page_for(set)
      set.instructions.dig(:paginate, :page)
    end

    def page_size_for(set)
      set.instructions.dig(:paginate, :size)
    end
  end
end
