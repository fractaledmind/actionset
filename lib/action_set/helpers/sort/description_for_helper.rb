# frozen_string_literal: true

require_relative './next_direction_for_helper'

module Sort
  module DescriptionForHelper
    include Sort::NextDirectionForHelper

    def sort_description_for(attribute)
      "sort by '#{attribute}' in #{next_sort_direction_for(attribute, format: :long)} order"
    end
  end
end
