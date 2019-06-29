# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module ActiveRecord
      module Operators
        BASE_PREDICATES = {
          EQ: {
            operator: :eq
          },
          NOT_EQ: {
            operator: :not_eq
          },
          IN: {
            operator: :in
          },
          NOT_IN: {
            operator: :not_in
          },
          MATCHES: {
            operator: :matches
          },
          DOES_NOT_MATCH: {
            operator: :does_not_match
          },
          LT: {
            operator: :lt
          },
          LTEQ: {
            operator: :lteq
          },
          GT: {
            operator: :gt
          },
          GTEQ: {
            operator: :gteq
          },
          BETWEEN: {
            operator: :between
          },
          NOT_BETWEEN: {
            operator: :not_between
          }
        }.freeze

        def self.get(operator_name)
          operator_key = operator_name.to_s.upcase.to_sym

          base_operator_hash = Constants::BASE_PREDICATES.fetch(operator_key, {})
          this_operator_hash = Operators::BASE_PREDICATES.fetch(operator_key, {})

          base_operator_hash.merge(this_operator_hash)
        end
      end
    end
  end
end
