# frozen_string_literal: true

require 'json'
require 'ostruct'

module Params
  module FormForObjectHelper
    def form_for_object_from_param(param)
      form_for_params = params.fetch(param, {})
      form_for_requirements = { model_name: { param_key: param } }

      JSON.parse(form_for_params.merge(form_for_requirements).to_json,
                 object_class: OpenStruct)
    end
  end
end
