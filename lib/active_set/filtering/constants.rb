# frozen_string_literal: true

class ActiveSet
  module Filtering
    # rubocop:disable Metrics/ModuleLength
    module Constants
      BLANK_VALUES = [nil, ''].freeze

      PREDICATES = {
        EQ: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: :'=='
        },
        NOT_EQ: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: :'!='
        },
        EQ_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E=='
        },
        EQ_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A=='
        },
        NOT_EQ_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E!='
        },
        NOT_EQ_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A!='
        },

        IN: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'<<'
        },
        NOT_IN: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'!<'
        },
        IN_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E<<'
        },
        IN_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A<<'
        },
        NOT_IN_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E!<'
        },
        NOT_IN_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A!<'
        },

        MATCHES: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: :'=~'
        },
        DOES_NOT_MATCH: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: :'!~'
        },
        MATCHES_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E=~'
        },
        MATCHES_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A=~'
        },
        DOES_NOT_MATCH_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E!~'
        },
        DOES_NOT_MATCH_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A!~'
        },

        LT: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: :'<'
        },
        LTEQ: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: :'<='
        },
        LT_ANY: {
          type: :binary,
          compound: true,
          behavior: :inconclusive,
          shorthand: :'E<'
        },
        LT_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A<'
        },
        LTEQ_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E<='
        },
        LTEQ_ALL: {
          type: :binary,
          compound: true,
          behavior: :inconclusive,
          shorthand: :'A<='
        },

        GT: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: :'>'
        },
        GTEQ: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: :'>='
        },
        GT_ANY: {
          type: :binary,
          compound: true,
          behavior: :inconclusive,
          shorthand: :'E>'
        },
        GT_ALL: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'A>'
        },
        GTEQ_ANY: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'E>='
        },
        GTEQ_ALL: {
          type: :binary,
          compound: true,
          behavior: :inconclusive,
          shorthand: :'A>='
        },

        BETWEEN: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: :'..'
        },
        NOT_BETWEEN: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: :'!.'
        },

        IS_TRUE: {
          type: :unary,
          operator: :eq,
          compound: false,
          behavior: :inconclusive,
          query_attribute_transformer: proc { |_| true }
        },
        IS_FALSE: {
          type: :unary,
          operator: :eq,
          compound: false,
          behavior: :inconclusive,
          query_attribute_transformer: proc { |_| false }
        },

        IS_NULL: {
          type: :unary,
          operator: :eq,
          compound: false,
          behavior: :exclusive,
          query_attribute_transformer: proc { |_| nil }
        },
        NOT_NULL: {
          type: :unary,
          operator: :not_eq,
          compound: false,
          behavior: :inclusive,
          query_attribute_transformer: proc { |_| nil }
        },

        IS_PRESENT: {
          type: :unary,
          operator: :not_eq_all,
          compound: false,
          behavior: :inclusive,
          query_attribute_transformer: proc { |_| BLANK_VALUES }
        },
        IS_BLANK: {
          type: :unary,
          operator: :eq_any,
          compound: false,
          behavior: :exclusive,
          query_attribute_transformer: proc { |_| BLANK_VALUES }
        },
      }.freeze
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
