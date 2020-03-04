# frozen_string_literal: true

require_relative './sort/link_for_helper'
require_relative './pagination/links_for_helper'
require_relative './pagination/record_description_for_helper'
require_relative './params/form_for_object_helper'
require_relative './export/path_for_helper'

module ActionSet
  module Helpers
    module HelperMethods
      include Sort::LinkForHelper
      include Pagination::LinksForHelper
      include Pagination::RecordDescriptionForHelper
      include Params::FormForObjectHelper
      include Export::PathForHelper
    end
  end
end
