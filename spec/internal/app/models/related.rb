# frozen_string_literal: true

class Related < ApplicationRecord
  has_many :things,
           through: :joint,
           inverse_of: :relateds
end
