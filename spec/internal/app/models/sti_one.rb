# frozen_string_literal: true

class StiOne < Sti
  has_many :polies, as: :polyable, dependent: :destroy
end
