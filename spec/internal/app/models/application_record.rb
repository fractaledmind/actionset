# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  FIELD_TYPES = %w[
    bignum
    binary
    boolean
    date
    datetime
    decimal
    float
    integer
    string
    symbol
    text
    time
  ].freeze

  def method_missing(method_name, *args, &block)
    return super unless method_name.to_s.start_with?('computed')

    field_method = method_name.to_s.remove 'computed_'
    send(field_method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    return super unless method_name.to_s.start_with?('computed')

    true
  end

  def bignum
    id**64
  end
  alias computed_bignum bignum

  def symbol
    string.to_sym
  end
  alias computed_symbol symbol
end
