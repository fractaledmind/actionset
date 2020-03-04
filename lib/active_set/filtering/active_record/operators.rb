# frozen_string_literal: true

require_relative '../constants'

class ActiveSet
  module Filtering
    module ActiveRecord
      # rubocop:disable Metrics/ModuleLength
      module Operators
        RANGE_TRANSFORMER = proc do |raw:, sql:, type:|
          if type.presence_in %i[boolean]
            Range.new(*sql.sort)
          else
            Range.new(*raw.sort)
          end
        end
        BLANK_TRANSFORMER = proc do |type:, **_ctx|
          if type.presence_in %i[date float integer]
            [nil]
          else
            Constants::BLANK_VALUES
          end
        end
        MATCHER_TRANSFORMER = proc do |sql:, type:, **ctx|
          next sql.map { |str| MATCHER_TRANSFORMER.call(sql: str, type: type, **ctx) } if sql.respond_to?(:map)

          next sql if type != :decimal
          next sql[0..-3] if sql.ends_with?('.0')
          next sql[0..-4] + '%' if sql.ends_with?('.0%')

          sql
        end
        START_MATCHER_TRANSFORMER = proc do |sql:, type:, **ctx|
          next sql.map { |str| START_MATCHER_TRANSFORMER.call(sql: str, type: type, **ctx) } if sql.respond_to?(:map)

          str = MATCHER_TRANSFORMER.call(sql: sql, type: type, **ctx)

          str + '%'
        end
        END_MATCHER_TRANSFORMER = proc do |sql:, type:, **ctx|
          next sql.map { |str| END_MATCHER_TRANSFORMER.call(sql: str, type: type, **ctx) } if sql.respond_to?(:map)

          str = MATCHER_TRANSFORMER.call(sql: sql, type: type, **ctx)

          '%' + str
        end
        CONTAIN_MATCHER_TRANSFORMER = proc do |sql:, type:, **ctx|
          next sql.map { |str| CONTAIN_MATCHER_TRANSFORMER.call(sql: str, type: type, **ctx) } if sql.respond_to?(:map)

          str = MATCHER_TRANSFORMER.call(sql: sql, type: type, **ctx)

          '%' + str + '%'
        end

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
            operator: :matches,
            query_attribute_transformer: MATCHER_TRANSFORMER
          },
          DOES_NOT_MATCH: {
            operator: :does_not_match,
            query_attribute_transformer: MATCHER_TRANSFORMER
          },
          MATCHES_ANY: {
            operator: :matches_any,
            query_attribute_transformer: MATCHER_TRANSFORMER
          },
          MATCHES_ALL: {
            operator: :matches_all,
            query_attribute_transformer: MATCHER_TRANSFORMER
          },
          DOES_NOT_MATCH_ANY: {
            operator: :does_not_match_any,
            query_attribute_transformer: MATCHER_TRANSFORMER
          },
          DOES_NOT_MATCH_ALL: {
            operator: :does_not_match_all,
            query_attribute_transformer: MATCHER_TRANSFORMER
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
            query_attribute_transformer: RANGE_TRANSFORMER
          },
          NOT_BETWEEN: {
            operator: :not_between,
            query_attribute_transformer: RANGE_TRANSFORMER
          },

          IS_TRUE: {
            operator: :eq,
            query_attribute_transformer: proc { |_| true }
          },
          IS_FALSE: {
            operator: :eq,
            query_attribute_transformer: proc { |_| false }
          },

          IS_NULL: {
            operator: :eq
          },
          NOT_NULL: {
            operator: :not_eq
          },

          IS_PRESENT: {
            operator: :not_eq_all,
            query_attribute_transformer: BLANK_TRANSFORMER
          },
          IS_BLANK: {
            operator: :eq_any,
            query_attribute_transformer: BLANK_TRANSFORMER
          },

          MATCH_START: {
            operator: :matches,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_START_ANY: {
            operator: :matches_any,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_START_ALL: {
            operator: :matches_all,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_NOT_START: {
            operator: :does_not_match,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_NOT_START_ANY: {
            operator: :does_not_match_any,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_NOT_START_ALL: {
            operator: :does_not_match_all,
            query_attribute_transformer: START_MATCHER_TRANSFORMER
          },
          MATCH_END: {
            operator: :matches,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_END_ANY: {
            operator: :matches_any,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_END_ALL: {
            operator: :matches_all,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_NOT_END: {
            operator: :does_not_match,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_NOT_END_ANY: {
            operator: :does_not_match_any,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_NOT_END_ALL: {
            operator: :does_not_match_all,
            query_attribute_transformer: END_MATCHER_TRANSFORMER
          },
          MATCH_CONTAIN: {
            operator: :matches,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_CONTAIN_ANY: {
            operator: :matches_any,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_CONTAIN_ALL: {
            operator: :matches_all,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_NOT_CONTAIN: {
            operator: :does_not_match,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_NOT_CONTAIN_ANY: {
            operator: :does_not_match_any,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          },
          MATCH_NOT_CONTAIN_ALL: {
            operator: :does_not_match_all,
            query_attribute_transformer: CONTAIN_MATCHER_TRANSFORMER
          }
        }.freeze

        def self.get(operator_name)
          operator_key = operator_name.to_s.upcase.to_sym

          base_operator_hash = Constants::PREDICATES.fetch(operator_key, {})
          this_operator_hash = Operators::PREDICATES.fetch(operator_key, {})

          base_operator_hash.merge(this_operator_hash)
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
