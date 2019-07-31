# frozen_string_literal: true

require_relative './record_range_for_helper'
require_relative './record_size_for_helper'

module Pagination
  module RecordDescriptionForHelper
    include Pagination::RecordRangeForHelper
    include Pagination::RecordSizeForHelper

    def pagination_record_description_for(set)
      [
        pagination_record_range_for(set),
        'of',
        "<strong>#{pagination_record_size_for(set)}</strong>",
        'records'
      ].join('&nbsp;').html_safe
    end
  end
end
