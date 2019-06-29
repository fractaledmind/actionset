# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module Enumerable
      module Operators
        BASE_PREDICATES = {
          EQ: {
            operator: :'=='
          },
          NOT_EQ: {
            operator: :'!='
          },
          IN: {
            operator: :presence_in
          },
          NOT_IN: {
            operator: :presence_in,
            result_transformer: ->(result) { !result }
          },
          MATCHES: {
            operator: :'=~',
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{attribute}/ }
          },
          DOES_NOT_MATCH: {
            operator: :'!~',
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{attribute}/ }
          },
          LT: {
            operator: :'<'
          },
          LTEQ: {
            operator: :'<='
          },
          GT: {
            operator: :'>'
          },
          GTEQ: {
            operator: :'>='
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
