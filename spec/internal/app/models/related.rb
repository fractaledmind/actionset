# frozen_string_literal: true

class Related < ApplicationRecord
  include Scopes

  has_many :things,
           through: :joint,
           inverse_of: :relateds
end
