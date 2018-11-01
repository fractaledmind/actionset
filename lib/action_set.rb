# frozen_string_literal: true

require 'rails/railtie'
require 'active_support/core_ext/object/blank'
require 'active_support/lazy_load_hooks'
require 'active_set'

require 'action_set/version'
require_relative './action_set/instruction/value'
require_relative './action_set/helpers/helper_methods'

module ActionSet
  # Ensure that the HelperMethods are callable from the Rails view-layer
  ActiveSupport.on_load :action_view do
    ::ActionView::Base.send :include, Helpers::HelperMethods
  end

  module ClassMethods
  end

  module InstanceMethods
    def process_set(set)
      paginate_set(sort_set(filter_set(ensure_active_set(set))))
    end

    def filter_set(set)
      active_set = ensure_active_set(set)
      active_set = active_set.filter(filter_structure(set)) if filter_params.any?
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
      exported_data = active_set.export(export_structure)
      send_data(exported_data, export_set_options(request.format))
    end

    private

    def filter_structure(set)
      filter_params.flatten_keys.reject { |_, v| v.blank? }.each_with_object({}) do |(keypath, value), memo|
        instruction = ActiveSet::AttributeInstruction.new(keypath, value)
        item_with_value = set.find { |i| !instruction.value_for(item: i).nil? }
        item_value = instruction.value_for(item: item_with_value)
        typecast_value = ActionSet::AttributeInstruction::Value.new(value)
                                           .cast(to: item_value.class)

        memo[keypath] = typecast_value
      end
    end

    def paginate_structure
      paginate_params.transform_values(&:to_i)
    end

    def export_structure
      {}.tap do |struct|
        struct[:format] = export_params[:format] || request.format.symbol
        columns_params = export_params[:columns]&.map do |column|
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

    def export_params
      params.fetch(:export, {}).to_unsafe_hash
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
