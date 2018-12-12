# frozen_string_literal: true

class StiTwo < Sti
  has_many :polies, as: :polyable, dependent: :destroy
end
