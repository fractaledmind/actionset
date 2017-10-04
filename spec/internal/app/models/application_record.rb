# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  COMPUTED_FIELDS = %w[
    bignum
    boolean
    date
    datetime
    float
    integer
    nil
    string
    symbol
    time
  ].freeze
  DB_FIELDS = %w[
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
end
