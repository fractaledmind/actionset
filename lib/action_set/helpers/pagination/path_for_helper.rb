# frozen_string_literal: true

require_relative '../params/current_helper'

module Pagination
  module PathForHelper
    include Params::CurrentHelper

    def pagination_path_for(page)
      page ||= 1
      url_for paginate_params_for(page)
    end

    private

    def paginate_params_for(page)
      current_params
        .deep_merge(paginate: {
                      page: page
                    })
    end
  end
end
