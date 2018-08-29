# frozen_string_literal: true

module Sort
  module PathForHelper
    def sort_path_for(attribute)
      url_for sort_params_for(attribute)
    end

    private

    def sort_params_for(attribute)
      current_params.merge(only_path: true,
                           sort: {
                             attribute => next_sort_direction_for(attribute)
                           })
    end
  end
end
