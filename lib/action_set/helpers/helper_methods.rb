# frozen_string_literal: true

require_relative './sort_linker'
require_relative './paginator'

module ActionSet
  module Helpers
    module HelperMethods
      def sort_link(column, title)
        Helpers::SortLinker.new(self).render(column, title)
      end

      def paginate(set)
        Helpers::Paginator.new(self).render(set)
      end
    end
  end
end
