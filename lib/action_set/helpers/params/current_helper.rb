# frozen_string_literal: true

module Params
  module CurrentHelper
    def current_params
      return params.to_unsafe_hash if params.respond_to? :to_unsafe_hash

      params
    end
  end
end
