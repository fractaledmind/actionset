# frozen_string_literal: true

module ActionSet
  module Helpers
    class Paginator
      def initialize(template)
        @template = template
        @info = {}
      end

      def render(set)
        @info = info_for_set(set)

        content_tag(:ul, class: 'pagination') do
          safe_join([
            link_to_first_page,
            link_to_prev_page,
            link_to_prev_gap,
            safe_join(relevant_page_numbers.map do |num|
              page = PageInterface.new(num, @info)
              link = link_to(page, page_link_url(page), rel: page.rel)
              content_tag(:li, link, class: ['page', (page.current? ? 'active' : nil)].compact)
            end),
            link_to_next_gap,
            link_to_next_page,
            link_to_last_page
          ].compact)
        end
      end

      private

      def info_for_set(set)
        {
          current_page: set.instructions.dig(:paginate, :page),
          page_size: set.instructions.dig(:paginate, :size),
          total_pages: (set.total_count.to_f / set.instructions.dig(:paginate, :size)).ceil,
          left_window_size: 2,
          right_window_size: 2
        }
      end

      def relevant_page_numbers
        current_page = [@info[:current_page]]
        left_window = [*(@info[:current_page] - @info[:left_window_size])..@info[:current_page]]
        right_window = [*@info[:current_page]..(@info[:current_page] + @info[:right_window_size])]

        (left_window | current_page | right_window).sort.reject { |x| (x < 1) || (x > @info[:total_pages]) }
      end

      def page_link_url(page_number)
        request.query_parameters
               .merge(controller: controller.controller_path,
                      action: controller.action_name,
                      paginate: {
                        page: page_number
                      })
      end

      def link_to_prev_gap
        return unless @info[:current_page] > 1
        return unless @info[:current_page] <= @info[:total_pages]
        return unless (@info[:current_page] - 1) > (@info[:left_window_size] + 1)

        link = link_to('…', '#', onclick: 'return false;')
        content_tag(:li, link, class: 'page prev_gap disabled')
      end

      def link_to_next_gap
        return unless @info[:current_page] >= 1
        return unless @info[:current_page] <= @info[:total_pages]
        return unless (@info[:total_pages] - @info[:current_page]) > (@info[:right_window_size] + 1)

        link = link_to('…', '#', onclick: 'return false;')
        content_tag(:li, link, class: 'page next_gap disabled')
      end

      def link_to_first_page
        return unless @info[:current_page] > 1

        link = link_to('« First', page_link_url(1))
        content_tag(:li, link, class: 'page first')
      end

      def link_to_prev_page
        return unless @info[:current_page] > 1
        return unless @info[:current_page] <= @info[:total_pages]

        link = link_to('‹ Prev', page_link_url(@info[:current_page] - 1), rel: 'prev')
        content_tag(:li, link, class: 'page prev')
      end

      def link_to_last_page
        return unless @info[:current_page] != @info[:total_pages]
        return unless @info[:current_page] <= @info[:total_pages]

        link = link_to('Last »', page_link_url(@info[:total_pages]))
        content_tag(:li, link, class: 'page last')
      end

      def link_to_next_page
        return unless @info[:current_page] != @info[:total_pages]
        return unless @info[:current_page] <= @info[:total_pages]

        link = link_to('Next ›', page_link_url(@info[:current_page] + 1), rel: 'next')
        content_tag(:li, link, class: 'page next')
      end

      # delegates view helper methods to @template
      def method_missing(name, *args, &block)
        @template.respond_to?(name) ? @template.send(name, *args, &block) : super
      end

      # Wraps a "page number" and provides some utility methods
      class PageInterface
        def initialize(page, info)
          @page = page
          @info = info
        end

        def number
          @page
        end

        def current?
          @page == @info[:current_page]
        end

        def first?
          @page == 1
        end

        def last?
          @page == @info[:total_pages]
        end

        def prev?
          @page == @info[:current_page] - 1
        end

        def next?
          @page == @info[:current_page] + 1
        end

        def rel
          return 'next' if next?
          return 'prev' if prev?
          nil
        end

        def out_of_range?
          @page > @info[:total_pages]
        end

        def to_i
          number
        end

        def to_s
          number.to_s
        end
      end
    end
  end
end
