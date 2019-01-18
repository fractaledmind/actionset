# frozen_string_literal: true

class ActiveSet
  module Filtering
    module ActiveRecord
      module Constants
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

        EQ = {
          type: :binary,
          operator: :eq,
          compound: false
        }.freeze
        EQ_ANY = {
          type: :binary,
          operator: :eq_any,
          compound: true
        }.freeze
        EQ_ALL = {
          type: :binary,
          operator: :eq_all,
          compound: true
        }.freeze
        NOT_EQ = {
          type: :binary,
          operator: :not_eq,
          compound: false
        }.freeze
        NOT_EQ_ANY = {
          type: :binary,
          operator: :not_eq_any,
          compound: true
        }.freeze
        NOT_EQ_ALL = {
          type: :binary,
          operator: :not_eq_all,
          compound: true
        }.freeze

        IN = {
          type: :binary,
          operator: :in,
          compound: true
        }.freeze
        IN_ANY = {
          type: :binary,
          operator: :in_any,
          compound: true
        }.freeze
        IN_ALL = {
          type: :binary,
          operator: :in_all,
          compound: true
        }.freeze
        NOT_IN = {
          type: :binary,
          operator: :not_in,
          compound: true
        }.freeze
        NOT_IN_ANY = {
          type: :binary,
          operator: :not_in_any,
          compound: true
        }.freeze
        NOT_IN_ALL = {
          type: :binary,
          operator: :not_in_all,
          compound: true
        }.freeze

        MATCHES = {
          type: :binary,
          operator: :matches,
          compound: false
        }.freeze
        MATCHES_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true
        }.freeze
        MATCHES_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true
        }.freeze
        DOES_NOT_MATCH = {
          type: :binary,
          operator: :does_not_match,
          compound: false
        }.freeze
        DOES_NOT_MATCH_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true
        }.freeze
        DOES_NOT_MATCH_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true
        }.freeze

        LT = {
          type: :binary,
          operator: :lt,
          compound: false
        }.freeze
        LT_ANY = {
          type: :binary,
          operator: :lt_any,
          compound: true
        }.freeze
        LT_ALL = {
          type: :binary,
          operator: :lt_all,
          compound: true
        }.freeze
        LTEQ = {
          type: :binary,
          operator: :lteq,
          compound: false
        }.freeze
        LTEQ_ANY = {
          type: :binary,
          operator: :lteq_any,
          compound: true
        }.freeze
        LTEQ_ALL = {
          type: :binary,
          operator: :lteq_all,
          compound: true
        }.freeze

        GT = {
          type: :binary,
          operator: :gt,
          compound: false
        }.freeze
        GT_ANY = {
          type: :binary,
          operator: :gt_any,
          compound: true
        }.freeze
        GT_ALL = {
          type: :binary,
          operator: :gt_all,
          compound: true
        }.freeze
        GTEQ = {
          type: :binary,
          operator: :gteq,
          compound: false
        }.freeze
        GTEQ_ANY = {
          type: :binary,
          operator: :gteq_any,
          compound: true
        }.freeze
        GTEQ_ALL = {
          type: :binary,
          operator: :gteq_all,
          compound: true
        }.freeze

        BETWEEN = {
          type: :binary,
          operator: :between,
          compound: true
        }.freeze
        NOT_BETWEEN = {
          type: :binary,
          operator: :not_between,
          compound: true
        }.freeze

        IS_TRUE = {
          type: :unary,
          operator: :eq,
          compound: false,
          value_transformer: proc { |_| true }
        }.freeze
        IS_FALSE = {
          type: :unary,
          operator: :eq,
          compound: false,
          value_transformer: proc { |_| false }
        }.freeze

        IS_NULL = {
          type: :unary,
          operator: :eq,
          compound: false,
          value_transformer: proc { |_| nil }
        }.freeze
        NOT_NULL = {
          type: :unary,
          operator: :not_eq,
          compound: false,
          value_transformer: proc { |_| nil }
        }.freeze

        IS_PRESENT = {
          type: :unary,
          operator: :not_eq_all,
          compound: false,
          value_transformer: proc { |_| BLANK_VALUES }
        }.freeze
        IS_BLANK = {
          type: :unary,
          operator: :eq_any,
          compound: false,
          value_transformer: proc { |_| BLANK_VALUES }
        }.freeze

        MATCH_START = {
          type: :binary,
          operator: :matches,
          compound: false,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_START_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_START_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_START = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_START_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_START_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          value_transformer: START_MATCHER_VALUE_TRANSFORMER
        }.freeze

        MATCH_END = {
          type: :binary,
          operator: :matches,
          compound: false,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_END_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_END_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_END = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_END_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_END_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          value_transformer: END_MATCHER_VALUE_TRANSFORMER
        }.freeze

        MATCH_CONTAIN = {
          type: :binary,
          operator: :matches,
          compound: false,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_CONTAIN_ANY = {
          type: :binary,
          operator: :matches_any,
          compound: true,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_CONTAIN_ALL = {
          type: :binary,
          operator: :matches_all,
          compound: true,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_CONTAIN = {
          type: :binary,
          operator: :does_not_match,
          compound: false,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_CONTAIN_ANY = {
          type: :binary,
          operator: :does_not_match_any,
          compound: true,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER
        }.freeze
        MATCH_NOT_CONTAIN_ALL = {
          type: :binary,
          operator: :does_not_match_all,
          compound: true,
          value_transformer: CONTAIN_MATCHER_VALUE_TRANSFORMER
        }.freeze


        OPERATORS = {
          eq: EQ,
          '==': EQ,
          eq_any: EQ_ANY,
          'E==': EQ_ANY,
          eq_all: EQ_ALL,
          'A==': EQ_ALL,
          not_eq: NOT_EQ,
          '!=': NOT_EQ,
          not_eq_any: NOT_EQ_ANY,
          'E!=': NOT_EQ_ANY,
          not_eq_all: NOT_EQ_ALL,
          'A!=': NOT_EQ_ALL,
          in: IN,
          '<<': IN,
          in_any: IN_ANY,
          'E<<': IN_ANY,
          in_all: IN_ALL,
          'A<<': IN_ALL,
          not_in: NOT_IN,
          '!<': NOT_IN,
          not_in_any: NOT_IN_ANY,
          'E!<': NOT_IN_ANY,
          not_in_all: NOT_IN_ALL,
          'A!<': NOT_IN_ALL,
          matches: MATCHES,
          '=~': MATCHES,
          matches_any: MATCHES_ANY,
          'E=~': MATCHES_ANY,
          matches_all: MATCHES_ALL,
          'A=~': MATCHES_ALL,
          does_not_match: DOES_NOT_MATCH,
          '!~': DOES_NOT_MATCH,
          does_not_match_any: DOES_NOT_MATCH_ANY,
          'E!~': DOES_NOT_MATCH_ANY,
          does_not_match_all: DOES_NOT_MATCH_ALL,
          'A!~': DOES_NOT_MATCH_ALL,
          lt: LT,
          '<': LT,
          lt_any: LT_ANY,
          'E<': LT_ANY,
          lt_all: LT_ALL,
          'A<': LT_ALL,
          lteq: LTEQ,
          '<=': LTEQ,
          lteq_any: LTEQ_ANY,
          'E<=': LTEQ_ANY,
          lteq_all: LTEQ_ALL,
          'A<=': LTEQ_ALL,
          gt: GT,
          '>': GT,
          gt_any: GT_ANY,
          'E>': GT_ANY,
          gt_all: GT_ALL,
          'A>': GT_ALL,
          gteq: GTEQ,
          '>=': GTEQ,
          gteq_any: GTEQ_ANY,
          'E>=': GTEQ_ANY,
          gteq_all: GTEQ_ALL,
          'A>=': GTEQ_ALL,
          between: BETWEEN,
          '..': BETWEEN,
          not_between: NOT_BETWEEN,
          '!.': NOT_BETWEEN,
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
          '~^': MATCH_START,
          start_any: MATCH_START_ANY,
          'E~^': MATCH_START_ANY,
          start_all: MATCH_START_ALL,
          'A~^': MATCH_START_ALL,
          not_start: MATCH_NOT_START,
          '!^': MATCH_NOT_START,
          not_start_any: MATCH_NOT_START_ANY,
          'E!^': MATCH_NOT_START_ANY,
          not_start_all: MATCH_NOT_START_ALL,
          'A!^': MATCH_NOT_START_ALL,
          end: MATCH_END,
          '~$': MATCH_END,
          end_any: MATCH_END_ANY,
          'E~$': MATCH_END_ANY,
          end_all: MATCH_END_ALL,
          'A~$': MATCH_END_ALL,
          not_end: MATCH_NOT_END,
          '!$': MATCH_NOT_END,
          not_end_any: MATCH_NOT_END_ANY,
          'E!$': MATCH_NOT_END_ANY,
          not_end_all: MATCH_NOT_END_ALL,
          'A!$': MATCH_NOT_END_ALL,
          contain: MATCH_CONTAIN,
          '~*': MATCH_CONTAIN,
          contain_any: MATCH_CONTAIN_ANY,
          'E~*': MATCH_CONTAIN_ANY,
          contain_all: MATCH_CONTAIN_ALL,
          'A~*': MATCH_CONTAIN_ALL,
          not_contain: MATCH_NOT_CONTAIN,
          '!*': MATCH_NOT_CONTAIN,
          not_contain_any: MATCH_NOT_CONTAIN_ANY,
          'E!*': MATCH_NOT_CONTAIN_ANY,
          not_contain_all: MATCH_NOT_CONTAIN_ALL,
          'A!*': MATCH_NOT_CONTAIN_ALL
        }.freeze
      end
    end
  end
end
