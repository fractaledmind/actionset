# frozen_string_literal: true

class Poly < ApplicationRecord
  include Scopes

  belongs_to :polyable, polymorphic: true
end
