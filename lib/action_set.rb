# frozen_string_literal: true

require 'rails/railtie'
require 'active_support/core_ext/object/blank'
require 'active_set'
require 'ostruct'

require 'action_set/version'
require_relative './action_set/instructions/entry_value'
require_relative './action_set/view_helpers'

module ActionSet
  class Railtie < ::Rails::Railtie
    initializer 'action_set.view_helpers' do
      ActiveSupport.on_load :action_view do
        include ViewHelpers
      end
    end
  end

  class Filter < OpenStruct
    def model_name
      OpenStruct.new(param_key: 'filter')
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def process_set(set)
      @set = set
      sort_set(filter_set(ActiveSet.new(set)))
    end

    def filter_set(set)
      @filters = JSON.parse(filter_params.to_json,
                            object_class: Filter)
      active_set = set.is_a?(ActiveSet) ? set : ActiveSet.new(set)
      active_set = active_set.filter(filter_structure) if filter_params.any?
      active_set
    end

    def sort_set(set)
      active_set = set.is_a?(ActiveSet) ? set : ActiveSet.new(set)
      active_set = active_set.sort(sort_params) if sort_params.any?
      active_set
    end

    private

    def filter_params
      params.fetch(:filter, {}).to_unsafe_hash
    end

    def filter_structure
      filter_params.flatten_keys.reject { |_, v| v.blank? }.each_with_object({}) do |(keypath, value), memo|
        instruction = ActiveSet::Instructions::Entry.new(keypath, value)
        item_with_value = @set.find { |i| !instruction.value_for(item: i).nil? }
        item_value = instruction.value_for(item: item_with_value)
        typecast_value = ActionSet::Instructions::EntryValue.new(value)
                                                            .cast(to: item_value.class)
        memo[keypath] = typecast_value
      end
    end

    def sort_params
      params.fetch(:sort, {}).to_unsafe_hash
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
