# frozen_string_literal: true

require 'action_set/version'
require 'active_set'

require_relative './action_set/instructions/entry_value'

module ActionSet
  module ClassMethods
  end

  module InstanceMethods
    def process_set(set)
      @set = set
      active_set = ActiveSet.new(set)
      active_set = active_set.filter(filter_structure) if filter_params.any?
      active_set = active_set.sort(sort_params) if sort_params.any?
      active_set
    end

    private

    def filter_params
      params.fetch(:filter, {}).to_unsafe_hash
    end

    def filter_structure
      filter_params.flatten_keys.reduce({}) do |memo, (keypath, value)|
        instruction = ActiveSet::Instructions::Entry.new(keypath, value)
        item_with_value = @set.find { |i| !instruction.value_for(item: i).nil? }
        item_value = instruction.value_for(item: item_with_value)
        typecast_value = ActionSet::Instructions::EntryValue.new(value)
                                                            .cast(to: item_value.class)
        memo[keypath] = typecast_value
        memo
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
