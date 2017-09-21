# frozen_string_literal: true

class Assoc < ApplicationRecord
  has_many :foos

  def method_missing(method_name, *args, &block)
    return super unless method_name.to_s.start_with?('calculated')
    return super unless method_name.to_s.ends_with?('field')
    field_method = method_name.to_s.remove 'calculated_', '_field'
    send(field_method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    return super unless method_name.to_s.start_with?('calculated')
    return super unless method_name.to_s.ends_with?('field')
    true
  end

  def calculated_bignum_field
    id**64
  end

  def calculated_symbol_field
    string.to_sym
  end

  def calculated_nil_field
    nil
  end
end
