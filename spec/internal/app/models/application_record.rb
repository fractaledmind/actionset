# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  DB_FIELD_TYPES = %w[
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

  FIELD_TYPES = (%w[
    bignum
    symbol
  ] + DB_FIELD_TYPES).freeze

  SORTABLE_TYPES = ApplicationRecord::FIELD_TYPES + ['string(i)']

  DB_FIELD_TYPES.each do |field|
    scope "#{field}_scope_method", ->(v) { where(field => v) }

    define_singleton_method("#{field}_collection_method") do |v|
      where(field => v)
    end

    define_singleton_method("#{field}_item_method") do |v|
      find_by(field => v)
    end

    define_singleton_method("#{field}_nil_method") do |_v|
      nil
    end
  end

  def method_missing(method_name, *args, &block)
    return super unless method_name.to_s.start_with?('computed')
    return super unless method_name.to_s.end_with?(*fields, *associations)

    field_method = method_name.to_s.remove 'computed_'
    send(field_method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    return super unless method_name.to_s.start_with?('computed')
    return super unless method_name.to_s.end_with?(*fields, *associations)

    true
  end

  def bignum
    id**64
  end
  alias computed_bignum bignum

  def symbol
    string&.to_sym
  end
  alias computed_symbol symbol

  def fields
    self.attributes.keys
  end

  def associations
    self.class.reflections.keys
  end
end
