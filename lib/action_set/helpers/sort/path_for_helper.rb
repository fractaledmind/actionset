# frozen_string_literal: true

require_relative '../params/current_helper'
require_relative './next_direction_for_helper'

module Sort
  module PathForHelper
    include Params::CurrentHelper
    include Sort::NextDirectionForHelper

    def sort_path_for(attribute)
      url_for sort_params_for(attribute)
    end

    private

    def sort_params_for(attribute)
      current_params
        .deep_merge(only_path: true,
                    sort: {
                      attribute => next_sort_direction_for(attribute)
                    })
    end
  end
end
