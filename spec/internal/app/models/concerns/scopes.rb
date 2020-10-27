require 'active_support/concern'

module Scopes
  extend ActiveSupport::Concern

  included do
    ApplicationRecord::DB_FIELD_TYPES.each do |field|
      scope "#{field}_scope_method", (lambda do |v|
        if ::ActiveRecord::Base.connection.adapter_name.downcase.presence_in(['mysql', 'mysql2']) && field == 'float'
          column = Arel::Nodes::NamedFunction.new('CAST', [arel_table[field].as('DECIMAL(8,2)')])
          where(column.eq(v))
        else
          where(field => v)
        end
      end)

      define_singleton_method("#{field}_collection_method") do |v|
        if ::ActiveRecord::Base.connection.adapter_name.downcase.presence_in(['mysql', 'mysql2']) && field == 'float'
          column = Arel::Nodes::NamedFunction.new('CAST', [arel_table[field].as('DECIMAL(8,2)')])
          where(column.eq(v))
        else
          where(field => v)
        end
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
