# frozen_string_literal: true

class Poly < ApplicationRecord
  belongs_to :polyable, polymorphic: true
end
