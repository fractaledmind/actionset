# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module Enumerable
      # rubocop:disable Metrics/ModuleLength
      module Operators
        NOT_TRANSFORMER = ->(result) { !result }
        RANGE_TRANSFORMER = ->(value) { Range.new(*value.sort) }
        REGEXP_TRANSFORMER = ->(value) { /#{Regexp.quote(value.to_s)}/ }
        STRING_TRANSFORMER = ->(value) { value.to_s }

        PREDICATES = {
          EQ: {
            operator: :'=='
          },
          NOT_EQ: {
            operator: :'!='
          },
          EQ_ANY: {
            operator: :'==',
            reducer: :any?
          },
          EQ_ALL: {
            operator: :'==',
            reducer: :all?
          },
          NOT_EQ_ANY: {
            operator: :'!=',
            reducer: :any?
          },
          NOT_EQ_ALL: {
            operator: :'!=',
            reducer: :all?
          },

          IN: {
            operator: :presence_in
          },
          NOT_IN: {
            operator: :presence_in,
            result_transformer: NOT_TRANSFORMER
          },
          IN_ANY: {
            operator: :presence_in,
            reducer: :any?
          },
          IN_ALL: {
            operator: :presence_in,
            reducer: :all?
          },
          NOT_IN_ANY: {
            operator: :presence_in,
            reducer: :any?,
            result_transformer: NOT_TRANSFORMER
          },
          NOT_IN_ALL: {
            operator: :presence_in,
            reducer: :all?,
            result_transformer: NOT_TRANSFORMER
          },

          MATCHES: {
            operator: :'=~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: REGEXP_TRANSFORMER
          },
          DOES_NOT_MATCH: {
            operator: :'!~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: REGEXP_TRANSFORMER
          },
          MATCHES_ANY: {
            operator: :'=~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: REGEXP_TRANSFORMER
          },
          MATCHES_ALL: {
            operator: :'=~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: REGEXP_TRANSFORMER
          },
          DOES_NOT_MATCH_ANY: {
            operator: :'!~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: REGEXP_TRANSFORMER
          },
          DOES_NOT_MATCH_ALL: {
            operator: :'!~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: REGEXP_TRANSFORMER
          },

          LT: {
            operator: :'<'
          },
          LTEQ: {
            operator: :'<='
          },
          LT_ANY: {
            operator: :'<',
            reducer: :any?
          },
          LT_ALL: {
            operator: :'<',
            reducer: :all?
          },
          LTEQ_ANY: {
            operator: :'<=',
            reducer: :any?
          },
          LTEQ_ALL: {
            operator: :'<=',
            reducer: :all?
          },

          GT: {
            operator: :'>'
          },
          GTEQ: {
            operator: :'>='
          },
          GT_ANY: {
            operator: :'>',
            reducer: :any?
          },
          GT_ALL: {
            operator: :'>',
            reducer: :all?
          },
          GTEQ_ANY: {
            operator: :'>=',
            reducer: :any?
          },
          GTEQ_ALL: {
            operator: :'>=',
            reducer: :all?
          },

          BETWEEN: {
            operator: :cover?,
            query_attribute_transformer: RANGE_TRANSFORMER
          },
          NOT_BETWEEN: {
            operator: :cover?,
            query_attribute_transformer: RANGE_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },

          IS_TRUE: {
            operator: :'==',
            query_attribute_transformer: proc { |_| 1 }
          },
          IS_FALSE: {
            operator: :'==',
            query_attribute_transformer: proc { |_| 0 }
          },

          IS_NULL: {
            operator: :'=='
          },
          NOT_NULL: {
            operator: :'!='
          },

          IS_PRESENT: {
            operator: :'!=',
            reducer: :all?,
            query_attribute_transformer: proc { |_| Constants::BLANK_VALUES }
          },
          IS_BLANK: {
            operator: :'==',
            reducer: :any?,
            query_attribute_transformer: proc { |_| Constants::BLANK_VALUES }
          },

          MATCH_START: {
            operator: :'start_with?',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_START_ANY: {
            operator: :'start_with?',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_START_ALL: {
            operator: :'start_with?',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_NOT_START: {
            operator: :'start_with?',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_NOT_START_ANY: {
            operator: :'start_with?',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_NOT_START_ALL: {
            operator: :'start_with?',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_END: {
            operator: :'end_with?',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_END_ANY: {
            operator: :'end_with?',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_END_ALL: {
            operator: :'end_with?',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_NOT_END: {
            operator: :'end_with?',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_NOT_END_ANY: {
            operator: :'end_with?',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_NOT_END_ALL: {
            operator: :'end_with?',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_CONTAIN: {
            operator: :'include?',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_CONTAIN_ANY: {
            operator: :'include?',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_CONTAIN_ALL: {
            operator: :'include?',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER
          },
          MATCH_NOT_CONTAIN: {
            operator: :'include?',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_NOT_CONTAIN_ANY: {
            operator: :'include?',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          },
          MATCH_NOT_CONTAIN_ALL: {
            operator: :'include?',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: STRING_TRANSFORMER,
            result_transformer: NOT_TRANSFORMER
          }
        }.freeze

        def self.get(operator_name)
          operator_key = operator_name.to_s.upcase.to_sym

          base_operator_hash = Constants::PREDICATES.fetch(operator_key, {})
          this_operator_hash = Operators::PREDICATES.fetch(operator_key, {})

          base_operator_hash.merge(this_operator_hash)
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
