# frozen_string_literal: true

require_relative './record_first_for_helper'
require_relative './record_last_for_helper'

module Pagination
  module RecordRangeForHelper
    include Pagination::RecordFirstForHelper
    include Pagination::RecordLastForHelper

    def pagination_record_range_for(set)
      [
        pagination_record_first_for(set),
        '&ndash;',
        pagination_record_last_for(set)
      ].join('&nbsp;').html_safe
    end
  end
end
