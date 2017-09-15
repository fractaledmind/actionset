# frozen_string_literal: true

require 'action_set/version'
require 'active_set'

module ActionSet
  module ClassMethods
  end

  module InstanceMethods
    def process_set(set)
      active_set = ActiveSet.new(set)
      active_set = active_set.filter(filter_params) if filter_params.any?
      active_set = active_set.sort(sort_params) if sort_params.any?
      active_set
    end

    private

    def filter_params
      params.fetch(:filter, {}).to_unsafe_hash
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
