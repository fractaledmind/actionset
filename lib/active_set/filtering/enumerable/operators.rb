# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module Enumerable
      module Operators
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
            result_transformer: ->(result) { !result }
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
            result_transformer: ->(result) { !result }
          },
          NOT_IN_ALL: {
            operator: :presence_in,
            reducer: :all?,
            result_transformer: ->(result) { !result }
          },

          MATCHES: {
            operator: :'=~',
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
          },
          DOES_NOT_MATCH: {
            operator: :'!~',
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
          },
          MATCHES_ANY: {
            operator: :'=~',
            reducer: :any?,
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
          },
          MATCHES_ALL: {
            operator: :'=~',
            reducer: :all?,
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
          },
          DOES_NOT_MATCH_ANY: {
            operator: :'!~',
            reducer: :any?,
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
          },
          DOES_NOT_MATCH_ALL: {
            operator: :'!~',
            reducer: :all?,
            object_attribute_transformer: ->(attribute) { attribute.to_s },
            query_attribute_transformer: ->(attribute) { /#{Regexp.quote(attribute.to_s)}/ }
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
            query_attribute_transformer: ->(query) { Range.new(*query.sort) }
          },
          NOT_BETWEEN: {
            operator: :cover?,
            query_attribute_transformer: ->(query) { Range.new(*query.sort) },
            result_transformer: ->(result) { !result }
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
