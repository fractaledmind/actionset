# frozen_string_literal: true

module ActionSet
  module Helpers
    class SortLinker
      def initialize(template)
        @template = template
      end

      def render(column, title = nil)
        column = column.to_s
        title ||= sort_link_title(column)

        @template.link_to title, sort_link_url(column)
      end

      private

      def sort_link_title(column)
        I18n.t(column,
               scope: :attributes,
               default: default_sort_link_title(column))
      end

      def sort_link_url(column)
        @template.request
                 .query_parameters
                 .merge(controller: @template.controller.controller_path,
                        action: @template.controller.action_name,
                        sort: {
                          column => sort_link_direction(column)
                        })
      end

      def sort_link_direction(column)
        return 'asc' unless sort_params_include_column?(column)
        return 'asc' unless sort_params_only_include_valid_directions?

        sort_direction_inverses = { 'asc' => 'desc', 'desc' => 'asc' }
        sort_direction_inverses[@template.params.dig(:sort, column).to_s]
      end

      def default_sort_link_title(column)
        ActiveSet::Instructions::Entry::KeyPath.new(column).titleized
      end

      def sort_params_include_column?(column)
        @template.params[:sort]&.keys&.include?(column.to_s)
      end

      def sort_params_only_include_valid_directions?
        (sort_params_directions - %w[asc desc]).empty?
      end

      def sort_params_directions
        @template.params[:sort]&.values&.map(&:to_s)&.uniq
      end
    end
  end
end
