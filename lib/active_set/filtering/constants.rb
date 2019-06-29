# frozen_string_literal: true

class ActiveSet
  module Filtering
    module Constants
      BASE_PREDICATES = {
        EQ: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: '=='.to_sym
        },
        NOT_EQ: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: '!='.to_sym
        },
        IN: {
          type: :binary,
          compound: true,
          behavior: :inclusive,
          shorthand: '<<'.to_sym
        },
        NOT_IN: {
          type: :binary,
          compound: true,
          behavior: :exclusive,
          shorthand: '!<'.to_sym
        },
        MATCHES: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: '=~'.to_sym
        },
        DOES_NOT_MATCH: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: '!~'.to_sym
        },
        LT: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: '<'.to_sym
        },
        LTEQ: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: '<='.to_sym
        },
        GT: {
          type: :binary,
          compound: false,
          behavior: :exclusive,
          shorthand: '>'.to_sym
        },
        GTEQ: {
          type: :binary,
          compound: false,
          behavior: :inclusive,
          shorthand: '>='.to_sym
        },
        BETWEEN: {
          type: :binary,
          compound: true,
          behavior: :inconclusive,
          shorthand: '..'.to_sym
        },
        NOT_BETWEEN: {
          type: :binary,
          compound: true,
          behavior: :inconclusive,
          shorthand: '!.'.to_sym
        }
      }.freeze
    end
  end
end

