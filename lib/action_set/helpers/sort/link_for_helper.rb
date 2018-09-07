# frozen_string_literal: true

require_relative './path_for_helper'
require_relative './description_for_helper'

module Sort
  module LinkForHelper
    include Sort::PathForHelper
    include Sort::DescriptionForHelper

    def sort_link_for(attribute, name = nil, **attributes)
      link_to(name || attribute.to_s.titleize,
              sort_path_for(attribute),
              **attributes.merge(
                'aria-label': sort_description_for(attribute)
              ))
    end
  end
end
