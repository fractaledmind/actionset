# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module Enumerable
      # rubocop:disable Metrics/ModuleLength
      module Operators
        RANGE_TRANSFORMER = ->(query) { Range.new(*query.sort) }
        NOT_TRANSFORMER = ->(result) { !result }
        STRING_TRANSFORMER = ->(attribute) { attribute.to_s }
        REGEXP_TRANSFORMER = ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
        START_MATCHER_TRANSFORMER = proc do |string_or_strings|
          next string_or_strings.map { |str| START_MATCHER_TRANSFORMER.call(str) } if string_or_strings.is_a?(Array)

          /#{Regexp.quote(string_or_strings.to_s) + '.*'}/
        end
        END_MATCHER_TRANSFORMER = proc do |string_or_strings|
          next string_or_strings.map { |str| END_MATCHER_TRANSFORMER.call(str) } if string_or_strings.is_a?(Array)

          /#{'.*' + Regexp.quote(string_or_strings.to_s)}/
        end
        CONTAIN_MATCHER_TRANSFORMER = proc do |string_or_strings|
          next string_or_strings.map { |str| CONTAIN_MATCHER_TRANSFORMER.call(str) } if string_or_strings.is_a?(Array)

          /#{'.*' + Regexp.quote(string_or_strings.to_s) + '.*'}/
        end

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
            operator: :'=~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_START_ANY: {
            operator: :'=~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_START_ALL: {
            operator: :'=~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_NOT_START: {
            operator: :'!~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_NOT_START_ANY: {
            operator: :'!~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_NOT_START_ALL: {
            operator: :'!~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_END: {
            operator: :'=~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_END_ANY: {
            operator: :'=~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_END_ALL: {
            operator: :'=~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_NOT_END: {
            operator: :'!~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_NOT_END_ANY: {
            operator: :'!~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_NOT_END_ALL: {
            operator: :'!~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_CONTAIN: {
            operator: :'=~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_CONTAIN_ANY: {
            operator: :'=~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_CONTAIN_ALL: {
            operator: :'=~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_NOT_CONTAIN: {
            operator: :'!~',
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_NOT_CONTAIN_ANY: {
            operator: :'!~',
            reducer: :any?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_NOT_CONTAIN_ALL: {
            operator: :'!~',
            reducer: :all?,
            object_attribute_transformer: STRING_TRANSFORMER,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
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
