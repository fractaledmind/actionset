require 'active_support/concern'

module Scopes
  extend ActiveSupport::Concern

  included do
    ApplicationRecord::DB_FIELD_TYPES.each do |field|
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
  end

  class_methods do
    # ...
  end
end
