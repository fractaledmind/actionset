# frozen_string_literal: true

module Sort
  module LinkForHelper
    def sort_link_for(attribute, name = nil)
      link_to(name || attribute.to_s.titleize,
              sort_path_for(attribute),
              'aria-label': sort_description_for(attribute))
    end
  end
end
