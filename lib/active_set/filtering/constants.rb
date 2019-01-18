# frozen_string_literal: true

require_relative '../attribute_instruction'
require_relative './enumerable_strategy'
require_relative './active_record_strategy'

class ActiveSet
  module Filtering
    module Constants
      BLANK_VALUES = [nil, ''].freeze

      EQ = {
        type: :binary,
        arel_operator: :eq,
        compound: false
      }.freeze
      EQ_ANY = {
        type: :binary,
        arel_operator: :eq_any,
        compound: true
      }.freeze
      EQ_ALL = {
        type: :binary,
        arel_operator: :eq_all,
        compound: true
      }.freeze
      NOT_EQ = {
        type: :binary,
        arel_operator: :not_eq,
        compound: false
      }.freeze
      NOT_EQ_ANY = {
        type: :binary,
        arel_operator: :not_eq_any,
        compound: true
      }.freeze
      NOT_EQ_ALL = {
        type: :binary,
        arel_operator: :not_eq_all,
        compound: true
      }.freeze

      IN = {
        type: :binary,
        arel_operator: :in,
        compound: true
      }.freeze
      IN_ANY = {
        type: :binary,
        arel_operator: :in_any,
        compound: true
      }.freeze
      IN_ALL = {
        type: :binary,
        arel_operator: :in_all,
        compound: true
      }.freeze
      NOT_IN = {
        type: :binary,
        arel_operator: :not_in,
        compound: true
      }.freeze
      NOT_IN_ANY = {
        type: :binary,
        arel_operator: :not_in_any,
        compound: true
      }.freeze
      NOT_IN_ALL = {
        type: :binary,
        arel_operator: :not_in_all,
        compound: true
      }.freeze

      MATCHES = {
        type: :binary,
        arel_operator: :matches,
        compound: false
      }.freeze
      MATCHES_ANY = {
        type: :binary,
        arel_operator: :matches_any,
        compound: true
      }.freeze
      MATCHES_ALL = {
        type: :binary,
        arel_operator: :matches_all,
        compound: true
      }.freeze
      DOES_NOT_MATCH = {
        type: :binary,
        arel_operator: :does_not_match,
        compound: false
      }.freeze
      DOES_NOT_MATCH_ANY = {
        type: :binary,
        arel_operator: :does_not_match_any,
        compound: true
      }.freeze
      DOES_NOT_MATCH_ALL = {
        type: :binary,
        arel_operator: :does_not_match_all,
        compound: true
      }.freeze

      LT = {
        type: :binary,
        arel_operator: :lt,
        compound: false
      }.freeze
      LT_ANY = {
        type: :binary,
        arel_operator: :lt_any,
        compound: true
      }.freeze
      LT_ALL = {
        type: :binary,
        arel_operator: :lt_all,
        compound: true
      }.freeze
      LTEQ = {
        type: :binary,
        arel_operator: :lteq,
        compound: false
      }.freeze
      LTEQ_ANY = {
        type: :binary,
        arel_operator: :lteq_any,
        compound: true
      }.freeze
      LTEQ_ALL = {
        type: :binary,
        arel_operator: :lteq_all,
        compound: true
      }.freeze

      GT = {
        type: :binary,
        arel_operator: :gt,
        compound: false
      }.freeze
      GT_ANY = {
        type: :binary,
        arel_operator: :gt_any,
        compound: true
      }.freeze
      GT_ALL = {
        type: :binary,
        arel_operator: :gt_all,
        compound: true
      }.freeze
      GTEQ = {
        type: :binary,
        arel_operator: :gteq,
        compound: false
      }.freeze
      GTEQ_ANY = {
        type: :binary,
        arel_operator: :gteq_any,
        compound: true
      }.freeze
      GTEQ_ALL = {
        type: :binary,
        arel_operator: :gteq_all,
        compound: true
      }.freeze

      BETWEEN = {
        type: :binary,
        arel_operator: :between,
        compound: true
      }.freeze
      NOT_BETWEEN = {
        type: :binary,
        arel_operator: :not_between,
        compound: true
      }.freeze

      IS_TRUE = {
        type: :unary,
        arel_operator: :eq,
        compound: false,
        value_transformer: proc { |_| true }
      }.freeze
      IS_FALSE = {
        type: :unary,
        arel_operator: :eq,
        compound: false,
        value_transformer: proc { |_| false }
      }.freeze

      IS_NULL = {
        type: :unary,
        arel_operator: :eq,
        compound: false,
        value_transformer: proc { |_| nil }
      }.freeze
      NOT_NULL = {
        type: :unary,
        arel_operator: :not_eq,
        compound: false,
        value_transformer: proc { |_| nil }
      }.freeze

      IS_PRESENT = {
        type: :unary,
        arel_operator: :not_eq_all,
        compound: false,
        value_transformer: proc { |_| BLANK_VALUES }
      }.freeze
      IS_BLANK = {
        type: :unary,
        arel_operator: :eq_any,
        compound: false,
        value_transformer: proc { |_| BLANK_VALUES }
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
        not_blank: IS_PRESENT
      }.freeze
    end
  end
end
