# frozen_string_literal: true

require 'active_support/core_ext/date/calculations'

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

        BLANK_VALUES = [nil, ''].freeze
        START_MATCHER_VALUE_TRANSFORMER = proc do |string_or_strings|
          return string_or_strings.map { |str| str + '%' } if string_or_strings.is_a?(Array)

          string_or_strings + '%'
        end
        END_MATCHER_VALUE_TRANSFORMER = proc do |string_or_strings|
          return string_or_strings.map { |str| '%' + str } if string_or_strings.is_a?(Array)

          '%' + string_or_strings
        end
        CONTAIN_MATCHER_VALUE_TRANSFORMER = proc do |string_or_strings|
          return string_or_strings.map { |str| '%' + str + '%' } if string_or_strings.is_a?(Array)

          '%' + string_or_strings + '%'
        end
        START_OF_DAY_VALUE_TRANSFORMER = proc do |date_or_dates|
          return date_or_dates.map { |date| date.beginning_of_day } if date_or_dates.is_a?(Array)

          date_or_dates.beginning_of_day
        end
        END_OF_DAY_VALUE_TRANSFORMER = proc do |date_or_dates|
          return date_or_dates.map { |date| date.end_of_day } if date_or_dates.is_a?(Array)

          date_or_dates.end_of_day
        end

        EQ = {
          type: :binary,
          operator: :eq,
          compound: false,
          identity: :inclusive,
          alias: '=='
        }.freeze
        EQ_ANY = {
          type: :binary,
          operator: :eq_any,
          compound: true,
          identity: :inclusive,
          alias: 'E=='
        }.freeze
        EQ_ALL = {
          type: :binary,
          operator: :eq_all,
          compound: true,
          identity: :exclusive,
          alias: 'A=='
        }.freeze
        NOT_EQ = {
          type: :binary,
          operator: :not_eq,
          compound: false,
          identity: :exclusive,
          alias: '!='
        }.freeze
        NOT_EQ_ANY = {
          type: :binary,
          operator: :not_eq_any,
          compound: true,
          identity: :inclusive,
          alias: 'E!='
        }.freeze
        NOT_EQ_ALL = {
          type: :binary,
          operator: :not_eq_all,
          compound: true,
          identity: :exclusive,
          alias: 'A!='
        }.freeze

        IN = {
          type: :binary,
          operator: :in,
          compound: true,
          identity: :inclusive,
          alias: '<<'
        }.freeze
        IN_ANY = {
          type: :binary,
          operator: :in_any,
          compound: true,
          identity: :inclusive,
          alias: 'E<<'
        }.freeze
        IN_ALL = {
          type: :binary,
          operator: :in_all,
          compound: true,
          identity: :exclusive,
          alias: 'A<<'
        }.freeze
        NOT_IN = {
          type: :binary,
          operator: :not_in,
          compound: true,
          identity: :exclusive,
          alias: '!<'
        }.freeze
        NOT_IN_ANY = {
          type: :binary,
          operator: :not_in_any,
          compound: true,
          identity: :inclusive,
          alias: 'E!<'
        }.freeze
        NOT_IN_ALL = {
          type: :binary,
          operator: :not_in_all,
          compound: true,
          identity: :exclusive,
          alias: 'A!<'
        }.freeze

        MATCHES = {
          type: :binary,
          operator: :matches,
          compound: false,
          identity: :inclusive,
          alias: '=~'
        }.freeze
        MATCHES_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          identity: :inclusive,
          alias: 'E=~'
        }.freeze
        MATCHES_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          identity: :exclusive,
          alias: 'A=~'
        }.freeze
        DOES_NOT_MATCH = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          identity: :exclusive,
          alias: '!~'
        }.freeze
        DOES_NOT_MATCH_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          identity: :inclusive,
          alias: 'E!~'
        }.freeze
        DOES_NOT_MATCH_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          identity: :exclusive,
          alias: 'A!~'
        }.freeze

        LT = {
          type: :binary,
          operator: :lt,
          compound: false,
          identity: :exclusive,
          alias: '<'
        }.freeze
        LT_ANY = {
          type: :binary,
          operator: :lt_any,
          compound: true,
          identity: :inconclusive,
          alias: 'E<'
        }.freeze
        LT_ALL = {
          type: :binary,
          operator: :lt_all,
          compound: true,
          identity: :exclusive,
          alias: 'A<'
        }.freeze
        LTEQ = {
          type: :binary,
          operator: :lteq,
          compound: false,
          identity: :inclusive,
          alias: '<='
        }.freeze
        LTEQ_ANY = {
          type: :binary,
          operator: :lteq_any,
          compound: true,
          identity: :inclusive,
          alias: 'E<='
        }.freeze
        LTEQ_ALL = {
          type: :binary,
          operator: :lteq_all,
          compound: true,
          identity: :inconclusive,
          alias: 'A<='
        }.freeze

        GT = {
          type: :binary,
          operator: :gt,
          compound: false,
          identity: :exclusive,
          alias: '>'
        }.freeze
        GT_ANY = {
          type: :binary,
          operator: :gt_any,
          compound: true,
          identity: :inconclusive,
          alias: 'E>'
        }.freeze
        GT_ALL = {
          type: :binary,
          operator: :gt_all,
          compound: true,
          identity: :exclusive,
          alias: 'A>'
        }.freeze
        GTEQ = {
          type: :binary,
          operator: :gteq,
          compound: false,
          identity: :inclusive,
          alias: '>='
        }.freeze
        GTEQ_ANY = {
          type: :binary,
          operator: :gteq_any,
          compound: true,
          identity: :inclusive,
          alias: 'E>='
        }.freeze
        GTEQ_ALL = {
          type: :binary,
          operator: :gteq_all,
          compound: true,
          identity: :inconclusive,
          alias: 'A>='
        }.freeze

        BETWEEN = {
          type: :binary,
          operator: :between,
          compound: true,
          alias: '..'
        }.freeze
        NOT_BETWEEN = {
          type: :binary,
          operator: :not_between,
          compound: true,
          alias: '!.'
        }.freeze

        IS_TRUE = {
          type: :unary,
          operator: :eq,
          compound: false,
          identity: :inconclusive,
          allowed_for: %i[boolean],
          value_transformer: proc { |_| true }
        }.freeze
        IS_FALSE = {
          type: :unary,
          operator: :eq,
          compound: false,
          identity: :inconclusive,
          allowed_for: %i[boolean],
          value_transformer: proc { |_| false }
        }.freeze

        IS_NULL = {
          type: :unary,
          operator: :eq,
          compound: false,
          identity: :exclusive,
          value_transformer: proc { |_| nil }
        }.freeze
        NOT_NULL = {
          type: :unary,
          operator: :not_eq,
          compound: false,
          identity: :inclusive,
          value_transformer: proc { |_| nil }
        }.freeze

        IS_PRESENT = {
          type: :unary,
          operator: :not_eq_all,
          compound: false,
          identity: :inclusive,
          allowed_for: FIELD_TYPES - %i[date float integer],
          value_transformer: proc { |_| BLANK_VALUES }
        }.freeze
        IS_BLANK = {
          type: :unary,
          operator: :eq_any,
          compound: false,
          identity: :exclusive,
          allowed_for: FIELD_TYPES - %i[date float integer],
          value_transformer: proc { |_| BLANK_VALUES }
        }.freeze

        MATCH_START = {
          type: :binary,
          operator: :matches,
          compound: false,
          identity: :inclusive,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER,
          alias: '~^'
        }.freeze
        MATCH_START_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          identity: :inclusive,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER,
          alias: 'E~^'
        }.freeze
        MATCH_START_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          identity: :exclusive,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER,
          alias: 'A~^'
        }.freeze
        MATCH_NOT_START = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          identity: :exclusive,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER,
          alias: '!^'
        }.freeze
        MATCH_NOT_START_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          identity: :inclusive,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER,
          alias: 'E!^'
        }.freeze
        MATCH_NOT_START_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          identity: :exclusive,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER,
          alias: 'A!^'
        }.freeze

        MATCH_END = {
          type: :binary,
          operator: :matches,
          compound: false,
          identity: :inclusive,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER,
          alias: '~$'
        }.freeze
        MATCH_END_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          identity: :inclusive,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER,
          alias: 'E~$'
        }.freeze
        MATCH_END_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          identity: :exclusive,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER,
          alias: 'A~$'
        }.freeze
        MATCH_NOT_END = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          identity: :exclusive,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER,
          alias: '!$'
        }.freeze
        MATCH_NOT_END_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          identity: :inclusive,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER,
          alias: 'E!$'
        }.freeze
        MATCH_NOT_END_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          identity: :exclusive,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER,
          alias: 'A!$'
        }.freeze

        MATCH_CONTAIN = {
          type: :binary,
          operator: :matches,
          compound: false,
          identity: :inclusive,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER,
          alias: '~*'
        }.freeze
        MATCH_CONTAIN_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          identity: :inclusive,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER,
          alias: 'E~*'
        }.freeze
        MATCH_CONTAIN_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          identity: :exclusive,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER,
          alias: 'A~*'
        }.freeze
        MATCH_NOT_CONTAIN = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          identity: :exclusive,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER,
          alias: '!*'
        }.freeze
        MATCH_NOT_CONTAIN_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          identity: :inclusive,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER,
          alias: 'E!*'
        }.freeze
        MATCH_NOT_CONTAIN_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          identity: :exclusive,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER,
          alias: 'A!*'
        }.freeze

        BEFORE_START_OF_DAY = {
          type: :binary,
          operator: :lt,
          compound: false,
          value_transformer: START_OF_DAY_VALUE_TRANSFORMER,
          alias: '<@^'
        }.freeze
        BEFORE_START_OF_DAY_ANY = {
          type: :binary,
          operator: :lt_any,
          compound: true,
          value_transformer: START_OF_DAY_VALUE_TRANSFORMER,
          alias: 'E<@^'
        }.freeze
        BEFORE_START_OF_DAY_ALL = {
          type: :binary,
          operator: :lt_all,
          compound: true,
          value_transformer: START_OF_DAY_VALUE_TRANSFORMER,
          alias: 'A<@^'
        }.freeze
        ON_OR_BEFORE_START_OF_DAY = {
          type: :binary,
          operator: :lteq,
          compound: false,
          value_transformer: START_OF_DAY_VALUE_TRANSFORMER,
          alias: '<=@^'
        }.freeze
        ON_OR_BEFORE_START_OF_DAY_ANY = {
          type: :binary,
          operator: :lteq_any,
          compound: true,
          value_transformer: START_OF_DAY_VALUE_TRANSFORMER,
          alias: 'E<=@^'
        }.freeze
        ON_OR_BEFORE_START_OF_DAY_ALL = {
          type: :binary,
          operator: :lteq_all,
          compound: true,
          value_transformer: START_OF_DAY_VALUE_TRANSFORMER,
          alias: 'A<=@^'
        }.freeze

        BEFORE_END_OF_DAY = {
          type: :binary,
          operator: :lt,
          compound: false,
          value_transformer: END_OF_DAY_VALUE_TRANSFORMER,
          alias: '<@$'
        }.freeze
        BEFORE_END_OF_DAY_ANY = {
          type: :binary,
          operator: :lt_any,
          compound: true,
          value_transformer: END_OF_DAY_VALUE_TRANSFORMER,
          alias: 'E<@$'
        }.freeze
        BEFORE_END_OF_DAY_ALL = {
          type: :binary,
          operator: :lt_all,
          compound: true,
          value_transformer: END_OF_DAY_VALUE_TRANSFORMER,
          alias: 'A<@$'
        }.freeze
        ON_OR_BEFORE_END_OF_DAY = {
          type: :binary,
          operator: :lteq,
          compound: false,
          value_transformer: END_OF_DAY_VALUE_TRANSFORMER,
          alias: '<=@$'
        }.freeze
        ON_OR_BEFORE_END_OF_DAY_ANY = {
          type: :binary,
          operator: :lteq_any,
          compound: true,
          value_transformer: END_OF_DAY_VALUE_TRANSFORMER,
          alias: 'E<=@$'
        }.freeze
        ON_OR_BEFORE_END_OF_DAY_ALL = {
          type: :binary,
          operator: :lteq_all,
          compound: true,
          value_transformer: END_OF_DAY_VALUE_TRANSFORMER,
          alias: 'A<=@$'
        }.freeze


        OPERATORS = {
          eq: EQ,
          eq_any: EQ_ANY,
          eq_all: EQ_ALL,
          not_eq: NOT_EQ,
          not_eq_any: NOT_EQ_ANY,
          not_eq_all: NOT_EQ_ALL,
          in: IN,
          in_any: IN_ANY,
          in_all: IN_ALL,
          not_in: NOT_IN,
          not_in_any: NOT_IN_ANY,
          not_in_all: NOT_IN_ALL,
          matches: MATCHES,
          matches_any: MATCHES_ANY,
          matches_all: MATCHES_ALL,
          does_not_match: DOES_NOT_MATCH,
          does_not_match_any: DOES_NOT_MATCH_ANY,
          does_not_match_all: DOES_NOT_MATCH_ALL,
          lt: LT,
          lt_any: LT_ANY,
          lt_all: LT_ALL,
          lteq: LTEQ,
          lteq_any: LTEQ_ANY,
          lteq_all: LTEQ_ALL,
          gt: GT,
          gt_any: GT_ANY,
          gt_all: GT_ALL,
          gteq: GTEQ,
          gteq_any: GTEQ_ANY,
          gteq_all: GTEQ_ALL,
          between: BETWEEN,
          not_between: NOT_BETWEEN,
          is_true: IS_TRUE,
          not_true: IS_FALSE,
          is_false: IS_FALSE,
          not_false: IS_TRUE,
          is_null: IS_NULL,
          not_null: NOT_NULL,
          is_present: IS_PRESENT,
          not_present: IS_BLANK,
          is_blank: IS_BLANK,
          not_blank: IS_PRESENT,
          start: MATCH_START,
          start_any: MATCH_START_ANY,
          start_all: MATCH_START_ALL,
          not_start: MATCH_NOT_START,
          not_start_any: MATCH_NOT_START_ANY,
          not_start_all: MATCH_NOT_START_ALL,
          end: MATCH_END,
          end_any: MATCH_END_ANY,
          end_all: MATCH_END_ALL,
          not_end: MATCH_NOT_END,
          not_end_any: MATCH_NOT_END_ANY,
          not_end_all: MATCH_NOT_END_ALL,
          contain: MATCH_CONTAIN,
          contain_any: MATCH_CONTAIN_ANY,
          contain_all: MATCH_CONTAIN_ALL,
          not_contain: MATCH_NOT_CONTAIN,
          not_contain_any: MATCH_NOT_CONTAIN_ANY,
          not_contain_all: MATCH_NOT_CONTAIN_ALL,
          before_start_of_day: BEFORE_START_OF_DAY,
          before_start_of_day_any: BEFORE_START_OF_DAY_ANY,
          before_start_of_day_all: BEFORE_START_OF_DAY_ALL,
          on_or_before_start_of_day: ON_OR_BEFORE_START_OF_DAY,
          on_or_before_start_of_day_any: ON_OR_BEFORE_START_OF_DAY_ANY,
          on_or_before_start_of_day_all: ON_OR_BEFORE_START_OF_DAY_ALL,
          before_end_of_day: BEFORE_END_OF_DAY,
          before_end_of_day_any: BEFORE_END_OF_DAY_ANY,
          before_end_of_day_all: BEFORE_END_OF_DAY_ALL,
          on_or_before_end_of_day: ON_OR_BEFORE_END_OF_DAY,
          on_or_before_end_of_day_any: ON_OR_BEFORE_END_OF_DAY_ANY,
          on_or_before_end_of_day_all: ON_OR_BEFORE_END_OF_DAY_ALL,
        }.freeze
      end
    end
  end
end
