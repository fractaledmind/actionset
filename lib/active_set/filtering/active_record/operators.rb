# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module ActiveRecord
      module Operators
        PREDICATES = {
          EQ: {
            operator: :eq
          },
          NOT_EQ: {
            operator: :not_eq
          },
          EQ_ANY: {
            operator: :eq_any
          },
          EQ_ALL: {
            operator: :eq_all
          },
          NOT_EQ_ANY: {
            operator: :not_eq_any
          },
          NOT_EQ_ALL: {
            operator: :not_eq_all
          },

          IN: {
            operator: :in
          },
          NOT_IN: {
            operator: :not_in
          },
          IN_ANY: {
            operator: :in_any
          },
          IN_ALL: {
            operator: :in_all
          },
          NOT_IN_ANY: {
            operator: :not_in_any
          },
          NOT_IN_ALL: {
            operator: :not_in_all
          },

          MATCHES: {
            operator: :matches
          },
          DOES_NOT_MATCH: {
            operator: :does_not_match
          },
          MATCHES_ANY: {
            operator: :matches_any
          },
          MATCHES_ALL: {
            operator: :matches_all
          },
          DOES_NOT_MATCH_ANY: {
            operator: :does_not_match_any
          },
          DOES_NOT_MATCH_ALL: {
            operator: :does_not_match_all
          },

          LT: {
            operator: :lt
          },
          LTEQ: {
            operator: :lteq
          },
          LT_ANY: {
            operator: :lt_any
          },
          LT_ALL: {
            operator: :lt_all
          },
          LTEQ_ANY: {
            operator: :lteq_any
          },
          LTEQ_ALL: {
            operator: :lteq_all
          },

          GT: {
            operator: :gt
          },
          GTEQ: {
            operator: :gteq
          },
          GT_ANY: {
            operator: :gt_any
          },
          GT_ALL: {
            operator: :gt_all
          },
          GTEQ_ANY: {
            operator: :gteq_any
          },
          GTEQ_ALL: {
            operator: :gteq_all
          },

          BETWEEN: {
            operator: :between,
            query_attribute_transformer: ->(query) { Range.new(*query.sort) }
          },
          NOT_BETWEEN: {
            operator: :not_between,
            query_attribute_transformer: ->(query) { Range.new(*query.sort) }
          }
        }.freeze

        def self.get(operator_name)
          operator_key = operator_name.to_s.upcase.to_sym

          base_operator_hash = Constants::PREDICATES.fetch(operator_key, {})
          this_operator_hash = Operators::PREDICATES.fetch(operator_key, {})

          base_operator_hash.merge(this_operator_hash)
        end
      end
    end
  end
end
