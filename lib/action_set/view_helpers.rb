# frozen_string_literal: true

module ActionSet
  module ViewHelpers
    def sort_link(column, title = nil)
      column = column.to_s
      title ||= sort_link_title(column)

      link_to title, sort_link_url(column)
    end

    private

    def sort_link_url(column)
      request.query_parameters.merge(controller: controller.controller_path,
                                     action: controller.action_name,
                                     sort: {
                                       column => sort_link_direction(column)
                                     })
    end

    def sort_link_title(column)
      I18n.t(column,
             scope: :attributes,
             default: default_sort_link_title(column))
    end

    def sort_link_direction(column)
      return 'asc' unless params[:sort]&.keys&.include?(column.to_s)

      sort_direction_inverses = { 'asc' => 'desc', 'desc' => 'asc' }
      sort_direction_inverses[params.dig(:sort, column)]
    end

    def default_sort_link_title(column)
      ActiveSet::Instructions::Entry::KeyPath.new(column).titleized
    end
  end
end
