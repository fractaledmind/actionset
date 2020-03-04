# frozen_string_literal: true

module Pagination
  module RecordSizeForHelper
    def pagination_record_size_for(set)
      set.instructions.dig(:paginate, :count)
    end
  end
end
