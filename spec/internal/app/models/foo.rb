# frozen_string_literal: true

class Foo < ApplicationRecord
  belongs_to :assoc

  scope :string_starts_with, (lambda do |substr|
    where(Arel::Table.new(table_name)[:string].matches("#{substr}%"))
  end)

  def self.string_ends_with(substr)
    where(Arel::Table.new(table_name)[:string].matches("%#{substr}"))
  end

  def computed_assoc
    assoc
  end
end
