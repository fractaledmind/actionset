# frozen_string_literal: true

class Foo < ApplicationRecord
  belongs_to :assoc

  def method_missing(method_name, *args, &block)
    return super unless method_name.to_s.start_with?('computed')
    return super unless method_name.to_s.ends_with?('field')
    field_method = method_name.to_s.remove 'computed_', '_field'
    send(field_method, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    return super unless method_name.to_s.start_with?('computed')
    return super unless method_name.to_s.ends_with?('field')
    true
  end

  def computed_bignum_field
    id**64
  end

  def computed_symbol_field
    string.to_sym
  end

  def computed_nil_field
    nil
  end

  def computed_relationship
    assoc
  end
end
