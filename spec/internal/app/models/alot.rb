# frozen_string_literal: true

class Alot < ApplicationRecord
  include Scopes

  belongs_to :thing,
             inverse_of: :alots
end
