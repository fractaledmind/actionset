# frozen_string_literal: true

class Only < ApplicationRecord
  has_one :things

  scope :string_starts_with, (lambda do |substr|
    where(Arel::Table.new(table_name)[:string].matches("#{substr}%"))
  end)

  def self.string_ends_with(substr)
    where(Arel::Table.new(table_name)[:string].matches("%#{substr}"))
  end
end
