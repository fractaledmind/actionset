# frozen_string_literal: true

class Only < ApplicationRecord
  include Scopes

  has_one :things
end
