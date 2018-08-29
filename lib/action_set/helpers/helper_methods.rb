# frozen_string_literal: true

require_relative './sort/current_direction_for_helper'
require_relative './sort/description_for_helper'
require_relative './sort/link_for_helper'
require_relative './sort/next_direction_for_helper'
require_relative './sort/path_for_helper'
require_relative './pagination/links_for_helper'
require_relative './pagination/path_for_helper'

module ActionSet
  module Helpers
    module HelperMethods
      include Sort::CurrentDirectionForHelper
      include Sort::DescriptionForHelper
      include Sort::LinkForHelper
      include Sort::NextDirectionForHelper
      include Sort::PathForHelper

      include Pagination::PathForHelper
      include Pagination::LinksForHelper
    end
  end
end
