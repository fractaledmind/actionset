# frozen_string_literal: true

require_relative '../params/current_helper'

module Export
  module PathForHelper
    include Params::CurrentHelper

    def export_path_for(format)
      url_for export_params_for(format)
    end

    private

    def export_params_for(format)
      current_params
        .deep_merge(only_path: true,
                    transform: {
                      format: format
                    })
    end
  end
end
