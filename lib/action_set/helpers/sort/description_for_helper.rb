# frozen_string_literal: true

module Sort
  module DescriptionForHelper
    def sort_description_for(attribute)
      "sort by '#{attribute}' in #{next_sort_direction_for(attribute, format: :long)} order"
    end
  end
end
