# frozen_string_literal: true

class Thing < ApplicationRecord
  belongs_to :only,
             optional: true
  has_many :alots,
           inverse_of: :thing
  has_many :relateds,
           through: :joint,
           inverse_of: :things

  scope :string_starts_with, (lambda do |substr|
    where(Arel::Table.new(table_name)[:string].matches("#{substr}%"))
  end)

  def self.string_ends_with(substr)
    where(Arel::Table.new(table_name)[:string].matches("%#{substr}"))
  end

  def computed_only
    only
  end
end
