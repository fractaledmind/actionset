# frozen_string_literal: true

class Joint < ApplicationRecord
  include Scopes

  belongs_to :thing,
             inverse_of: :joints
  belongs_to :related,
             inverse_of: :joints
end
