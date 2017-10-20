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
      @filters = JSON.parse(filter_params.to_json,
                            object_class: Filter)
      active_set = ActiveSet.new(set)
      active_set = active_set.filter(filter_structure) if filter_params.any?
      active_set = active_set.sort(sort_params) if sort_params.any?
      active_set
    end

    def export_set(set)
      return send_file(set, export_set_options(request.format)) if set.is_a?(String) && File.file?(set)
      active_set = set.is_a?(ActiveSet) ? set : ActiveSet.new(set)
      transformed_data = active_set.transform(transform_structure)
      send_data(transformed_data, export_set_options(request.format))
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

    def transform_structure
      {}.tap do |struct|
        struct[:format] = transform_params[:format] || request.format.symbol
        columns_params = transform_params[:columns]&.map do |column|
          Hash[column&.map do |k, v|
            is_literal_value = ->(key) { key.to_s == 'value*' }
            key = is_literal_value.(k) ? 'value' : k
            val = is_literal_value.(k) ? send(v) : v
            [key, val]
          end]
        end
        struct[:columns] = columns_params || send(:export_set_columns) || []
      end
    end

    def sort_params
      params.fetch(:sort, {}).to_unsafe_hash
    end

    def transform_params
      params.fetch(:transform, {}).to_unsafe_hash
    end

    def export_set_options(format)
      {}.tap do |opts|
        opts[:type] = format.to_s
        opts[:filename] = "#{Time.zone.now.strftime('%Y%m%d_%H:%M:%S')}.#{format.symbol}"
        opts[:disposition] = :inline if %w[development test].include?(Rails.env.to_s)
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
