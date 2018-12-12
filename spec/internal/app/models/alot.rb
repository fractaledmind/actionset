# frozen_string_literal: true

class Alot < ApplicationRecord
  belongs_to :thing,
             inverse_of: :alots
end
