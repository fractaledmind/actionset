# frozen_string_literal: true

require 'json'
require 'ostruct'

module Params
  module FormForObjectHelper
    def form_for_object_from_param(param, defaults = {})
      form_for_params = current_params.fetch(param, {})
      form_for_requirements = { model_name: { param_key: param } }
      form_for_hash = defaults.merge(form_for_params).merge(form_for_requirements)

      JSON.parse(form_for_hash.to_json,
                 object_class: OpenStruct)
    end
  end
end
