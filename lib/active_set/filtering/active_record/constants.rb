# frozen_string_literal: true

class ActiveSet
  module Filtering
    module ActiveRecord
      module Constants
        FIELD_TYPES = %i[
          binary
          boolean
          date
          datetime
          decimal
          float
          integer
          string
          text
          time
        ].freeze

        BLANK_VALUES = [
          nil,
          ''
        ].freeze

        START_MATCHER_TRANSFORMER = proc do |string_or_strings|
          next string_or_strings.map { |str| str + '%' } if string_or_strings.is_a?(Array)

          string_or_strings + '%'
        end
        END_MATCHER_TRANSFORMER = proc do |string_or_strings|
          next string_or_strings.map { |str| '%' + str } if string_or_strings.is_a?(Array)

          '%' + string_or_strings
        end
        CONTAIN_MATCHER_TRANSFORMER = proc do |string_or_strings|
          next string_or_strings.map { |str| '%' + str + '%' } if string_or_strings.is_a?(Array)

          '%' + string_or_strings + '%'
        end

        TIME_BEGINNING_OF_DAY_TRANSFORMER = proc { |_| Time.utc(2000,1,1).beginning_of_day }
        TIME_MIDDLE_OF_DAY_TRANSFORMER = proc { |_| Time.utc(2000,1,1).middle_of_day }
        TIME_END_OF_DAY_TRANSFORMER = proc { |_| Time.utc(2000,1,1).end_of_day }

        AREL_OPERATORS = [
          {
            name: :EQ,
            type: :binary,
            operator: :eq,
            compound: false,
            matching_behavior: :inclusive,
            shorthand: '=='.to_sym
          },
          {
            name: :EQ_ANY,
            type: :binary,
            operator: :eq_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E=='.to_sym
          },
          {
            name: :EQ_ALL,
            type: :binary,
            operator: :eq_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A=='.to_sym
          },
          {
            name: :NOT_EQ,
            type: :binary,
            operator: :not_eq,
            compound: false,
            matching_behavior: :exclusive,
            shorthand: '!='.to_sym
          },
          {
            name: :NOT_EQ_ANY,
            type: :binary,
            operator: :not_eq_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E!='.to_sym
          },
          {
            name: :NOT_EQ_ALL,
            type: :binary,
            operator: :not_eq_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A!='.to_sym
          },
          {
            name: :IN,
            type: :binary,
            operator: :in,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: '<<'.to_sym
          },
          {
            name: :IN_ANY,
            type: :binary,
            operator: :in_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E<<'.to_sym
          },
          {
            name: :IN_ALL,
            type: :binary,
            operator: :in_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A<<'.to_sym
          },
          {
            name: :NOT_IN,
            type: :binary,
            operator: :not_in,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: '!<'.to_sym
          },
          {
            name: :NOT_IN_ANY,
            type: :binary,
            operator: :not_in_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E!<'.to_sym
          },
          {
            name: :NOT_IN_ALL,
            type: :binary,
            operator: :not_in_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A!<'.to_sym
          },
          {
            name: :MATCHES,
            type: :binary,
            operator: :matches,
            compound: false,
            matching_behavior: :inclusive,
            shorthand: '=~'.to_sym
          },
          {
            name: :MATCHES_ANY,
            type: :binary,
            operator: :matches_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E=~'.to_sym
          },
          {
            name: :MATCHES_ALL,
            type: :binary,
            operator: :matches_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A=~'.to_sym
          },
          {
            name: :DOES_NOT_MATCH,
            type: :binary,
            operator: :does_not_match,
            compound: false,
            matching_behavior: :exclusive,
            shorthand: '!~'.to_sym
          },
          {
            name: :DOES_NOT_MATCH_ANY,
            type: :binary,
            operator: :does_not_match_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E!~'.to_sym
          },
          {
            name: :DOES_NOT_MATCH_ALL,
            type: :binary,
            operator: :does_not_match_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A!~'.to_sym
          },
          {
            name: :LT,
            type: :binary,
            operator: :lt,
            compound: false,
            matching_behavior: :exclusive,
            shorthand: '<'.to_sym
          },
          {
            name: :LT_ANY,
            type: :binary,
            operator: :lt_any,
            compound: true,
            matching_behavior: :inconclusive,
            shorthand: 'E<'.to_sym
          },
          {
            name: :LT_ALL,
            type: :binary,
            operator: :lt_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A<'.to_sym
          },
          {
            name: :LTEQ,
            type: :binary,
            operator: :lteq,
            compound: false,
            matching_behavior: :inclusive,
            shorthand: '<='.to_sym
          },
          {
            name: :LTEQ_ANY,
            type: :binary,
            operator: :lteq_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E<='.to_sym
          },
          {
            name: :LTEQ_ALL,
            type: :binary,
            operator: :lteq_all,
            compound: true,
            matching_behavior: :inconclusive,
            shorthand: 'A<='.to_sym
          },
          {
            name: :GT,
            type: :binary,
            operator: :gt,
            compound: false,
            matching_behavior: :exclusive,
            shorthand: '>'.to_sym
          },
          {
            name: :GT_ANY,
            type: :binary,
            operator: :gt_any,
            compound: true,
            matching_behavior: :inconclusive,
            shorthand: 'E>'.to_sym
          },
          {
            name: :GT_ALL,
            type: :binary,
            operator: :gt_all,
            compound: true,
            matching_behavior: :exclusive,
            shorthand: 'A>'.to_sym
          },
          {
            name: :GTEQ,
            type: :binary,
            operator: :gteq,
            compound: false,
            matching_behavior: :inclusive,
            shorthand: '>='.to_sym
          },
          {
            name: :GTEQ_ANY,
            type: :binary,
            operator: :gteq_any,
            compound: true,
            matching_behavior: :inclusive,
            shorthand: 'E>='.to_sym
          },
          {
            name: :GTEQ_ALL,
            type: :binary,
            operator: :gteq_all,
            compound: true,
            matching_behavior: :inconclusive,
            shorthand: 'A>='.to_sym
          },
          {
            name: :BETWEEN,
            type: :binary,
            operator: :between,
            compound: true,
            matching_behavior: :inconclusive,
            shorthand: '..'.to_sym
          },
          {
            name: :NOT_BETWEEN,
            type: :binary,
            operator: :not_between,
            compound: true,
            matching_behavior: :inconclusive,
            shorthand: '!.'.to_sym
          }
        ].freeze

        PREDICATE_OPERATORS = [
          {
            name: :IS_TRUE,
            type: :unary,
            operator: :eq,
            compound: false,
            matching_behavior: :inconclusive,
            allowed_for: FIELD_TYPES & %i[boolean],
            transformer: proc { |_| true }
          },
          {
            name: :IS_FALSE,
            type: :unary,
            operator: :eq,
            compound: false,
            matching_behavior: :inconclusive,
            allowed_for: FIELD_TYPES & %i[boolean],
            transformer: proc { |_| false }
          },
          {
            name: :IS_NULL,
            type: :unary,
            operator: :eq,
            compound: false,
            matching_behavior: :exclusive,
            transformer: proc { |_| nil }
          },
          {
            name: :NOT_NULL,
            type: :unary,
            operator: :not_eq,
            compound: false,
            matching_behavior: :inclusive,
            transformer: proc { |_| nil }
          },
          {
            name: :IS_PRESENT,
            type: :unary,
            operator: :not_eq_all,
            compound: false,
            matching_behavior: :inclusive,
            allowed_for: FIELD_TYPES - %i[date float integer],
            transformer: proc { |_| BLANK_VALUES }
          },
          {
            name: :IS_BLANK,
            type: :unary,
            operator: :eq_any,
            compound: false,
            matching_behavior: :exclusive,
            allowed_for: FIELD_TYPES - %i[date float integer],
            transformer: proc { |_| BLANK_VALUES }
          }
        ].freeze

        MATCHING_OPERATORS = [
          {
            name: :MATCH_START,
            type: :binary,
            operator: :matches,
            compound: false,
            matching_behavior: :inclusive,
            transformer: START_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: '~^'.to_sym
          },
          {
            name: :MATCH_START_ANY,
            type: :binary,
            operator: :matches_any,
            compound: true,
            matching_behavior: :inclusive,
            transformer: START_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'E~^'.to_sym
          },
          {
            name: :MATCH_START_ALL,
            type: :binary,
            operator: :matches_all,
            compound: true,
            matching_behavior: :exclusive,
            transformer: START_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'A~^'.to_sym
          },
          {
            name: :MATCH_NOT_START,
            type: :binary,
            operator: :does_not_match,
            compound: false,
            matching_behavior: :exclusive,
            transformer: START_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: '!^'.to_sym
          },
          {
            name: :MATCH_NOT_START_ANY,
            type: :binary,
            operator: :does_not_match_any,
            compound: true,
            matching_behavior: :inclusive,
            transformer: START_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'E!^'.to_sym
          },
          {
            name: :MATCH_NOT_START_ALL,
            type: :binary,
            operator: :does_not_match_all,
            compound: true,
            matching_behavior: :exclusive,
            transformer: START_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'A!^'.to_sym
          },
          {
            name: :MATCH_END,
            type: :binary,
            operator: :matches,
            compound: false,
            matching_behavior: :inclusive,
            transformer: END_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: '~$'.to_sym
          },
          {
            name: :MATCH_END_ANY,
            type: :binary,
            operator: :matches_any,
            compound: true,
            matching_behavior: :inclusive,
            transformer: END_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'E~$'.to_sym
          },
          {
            name: :MATCH_END_ALL,
            type: :binary,
            operator: :matches_all,
            compound: true,
            matching_behavior: :exclusive,
            transformer: END_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'A~$'.to_sym
          },
          {
            name: :MATCH_NOT_END,
            type: :binary,
            operator: :does_not_match,
            compound: false,
            matching_behavior: :exclusive,
            transformer: END_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: '!$'.to_sym
          },
          {
            name: :MATCH_NOT_END_ANY,
            type: :binary,
            operator: :does_not_match_any,
            compound: true,
            matching_behavior: :inclusive,
            transformer: END_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'E!$'.to_sym
          },
          {
            name: :MATCH_NOT_END_ALL,
            type: :binary,
            operator: :does_not_match_all,
            compound: true,
            matching_behavior: :exclusive,
            transformer: END_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'A!$'.to_sym
          },
          {
            name: :MATCH_CONTAIN,
            type: :binary,
            operator: :matches,
            compound: false,
            matching_behavior: :inclusive,
            transformer: CONTAIN_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: '~*'.to_sym
          },
          {
            name: :MATCH_CONTAIN_ANY,
            type: :binary,
            operator: :matches_any,
            compound: true,
            matching_behavior: :inclusive,
            transformer: CONTAIN_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'E~*'.to_sym
          },
          {
            name: :MATCH_CONTAIN_ALL,
            type: :binary,
            operator: :matches_all,
            compound: true,
            matching_behavior: :exclusive,
            transformer: CONTAIN_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'A~*'.to_sym
          },
          {
            name: :MATCH_NOT_CONTAIN,
            type: :binary,
            operator: :does_not_match,
            compound: false,
            matching_behavior: :exclusive,
            transformer: CONTAIN_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: '!*'.to_sym
          },
          {
            name: :MATCH_NOT_CONTAIN_ANY,
            type: :binary,
            operator: :does_not_match_any,
            compound: true,
            matching_behavior: :inclusive,
            transformer: CONTAIN_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'E!*'.to_sym
          },
          {
            name: :MATCH_NOT_CONTAIN_ALL,
            type: :binary,
            operator: :does_not_match_all,
            compound: true,
            matching_behavior: :exclusive,
            transformer: CONTAIN_MATCHER_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[binary string text],
            shorthand: 'A!*'.to_sym
          }
        ].freeze

        TIME_OPERATORS = [
          {
            name: :TIME_ON_START_OF_DAY,
            type: :unary,
            operator: :eq,
            compound: false,
            matching_behavior: :inconclusive,
            transformer: TIME_BEGINNING_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '=@^'.to_sym
          },
          {
            name: :TIME_AFTER_START_OF_DAY,
            type: :unary,
            operator: :gt,
            compound: false,
            matching_behavior: :exclusive,
            transformer: TIME_BEGINNING_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '>@^'.to_sym
          },
          {
            name: :TIME_ON_OR_AFTER_START_OF_DAY,
            type: :unary,
            operator: :gteq,
            compound: false,
            matching_behavior: :inclusive,
            transformer: TIME_BEGINNING_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '>=@^'.to_sym
          },
          {
            name: :TIME_BEFORE_MIDDLE_OF_DAY,
            type: :unary,
            operator: :lt,
            compound: false,
            matching_behavior: :exclusive,
            transformer: TIME_MIDDLE_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '<@v'.to_sym
          },
          {
            name: :TIME_ON_OR_BEFORE_MIDDLE_OF_DAY,
            type: :unary,
            operator: :lteq,
            compound: false,
            matching_behavior: :inclusive,
            transformer: TIME_MIDDLE_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '<=@v'.to_sym
          },
          {
            name: :TIME_ON_OR_AFTER_MIDDLE_OF_DAY,
            type: :unary,
            operator: :gteq,
            compound: false,
            matching_behavior: :inclusive,
            transformer: TIME_MIDDLE_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '>=@v'.to_sym
          },
          {
            name: :TIME_BEFORE_END_OF_DAY,
            type: :unary,
            operator: :lt,
            compound: false,
            matching_behavior: :exclusive,
            transformer: TIME_END_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '<@$'.to_sym
          },
          {
            name: :TIME_ON_OR_BEFORE_END_OF_DAY,
            type: :unary,
            operator: :lteq,
            compound: false,
            matching_behavior: :inclusive,
            transformer: TIME_END_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '<=@$'.to_sym
          },
          {
            name: :TIME_ON_END_OF_DAY,
            type: :unary,
            operator: :gteq,
            compound: false,
            matching_behavior: :inclusive,
            transformer: TIME_END_OF_DAY_TRANSFORMER,
            allowed_for: FIELD_TYPES & %i[time],
            shorthand: '=@$'.to_sym
          },
        ].freeze
      end
    end
  end
end
