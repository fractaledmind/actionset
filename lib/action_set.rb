# frozen_string_literal: true

require 'rails/railtie'
require 'active_support/core_ext/object/blank'
require 'active_support/lazy_load_hooks'
require 'active_set'
require 'ostruct'

require 'action_set/version'
require_relative './action_set/instructions/entry_value'
require_relative './action_set/helpers/helper_methods'

module ActionSet
  # Ensure that the HelperMethods are callable from the Rails view-layer
  ActiveSupport.on_load :action_view do
    ::ActionView::Base.send :include, Helpers::HelperMethods
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
      paginate_set(sort_set(filter_set(ActiveSet.new(set))))
    end

    def filter_set(set)
      set_filters_ivar
      active_set = ensure_active_set(set)
      active_set = active_set.filter(filter_structure) if filter_params.any?
      active_set
    end

    def sort_set(set)
      active_set = ensure_active_set(set)
      active_set = active_set.sort(sort_params) if sort_params.any?
      active_set
    end

    def paginate_set(set)
      active_set = ensure_active_set(set)
      active_set = active_set.paginate(paginate_structure)
      active_set
    end

    def export_set(set)
      return send_file(set, export_set_options(request.format)) if set.is_a?(String) && File.file?(set)
      active_set = ensure_active_set(set)
      transformed_data = active_set.transform(transform_structure)
      send_data(transformed_data, export_set_options(request.format))
    end

    def set_filters_ivar
      @filters = JSON.parse(filter_params.to_json,
                            object_class: Filter)
    end

    private

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

    def paginate_structure
      paginate_params.transform_values(&:to_i)
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

    def filter_params
      params.fetch(:filter, {}).to_unsafe_hash
    end

    def sort_params
      params.fetch(:sort, {}).to_unsafe_hash
    end

    def paginate_params
      params.fetch(:paginate, {}).to_unsafe_hash
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

    def ensure_active_set(set)
      return set if set.is_a?(ActiveSet)

      ActiveSet.new(set)
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
