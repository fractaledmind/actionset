# frozen_string_literal: true

class ActiveSet
  module Paginating
    class EnumerableStrategy
      def initialize(set, operation_instructions)
        @set = set
        @operation_instructions = operation_instructions
      end

      def execute
        return [] if @set.count <= @operation_instructions[:size] &&
                     @operation_instructions[:page] > 1

        @set[page_start..page_end] || []
      end

      private

      def page_start
        return 0 if @operation_instructions[:page] == 1

        @operation_instructions[:size] * (@operation_instructions[:page] - 1)
      end

      def page_end
        return page_start if @operation_instructions[:size] == 1

        page_start + @operation_instructions[:size] - 1
      end
    end
  end
end
