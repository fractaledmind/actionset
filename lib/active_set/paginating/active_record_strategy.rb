# frozen_string_literal: true

class ActiveSet
  module Paginating
    class ActiveRecordStrategy
      def initialize(set, operation_instructions)
        @set = set
        @operation_instructions = operation_instructions
      end

      def execute
        return false unless @set.respond_to? :to_sql
        return @set.none if @set.length <= @operation_instructions[:size] &&
                            @operation_instructions[:page] > 1

        @set.limit(@operation_instructions[:size]).offset(page_offset)
      end

      private

      def page_offset
        return 0 if @operation_instructions[:page] == 1

        @operation_instructions[:size] * (@operation_instructions[:page] - 1)
      end
    end
  end
end
