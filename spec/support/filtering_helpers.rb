# frozen_string_literal: true

module FilteringHelpers
  def all_possible_scope_paths_for(type)
    %W[
      #{type}_scope_method
      #{type}_collection_method
      #{type}_item_method
      #{type}_nil_method
    ].flat_map do |method_name|
      all_possible_paths_for(method_name, computed_fields: false)
    end
  end

  def filter_value_for(object:, path:)
    path = path.remove('_scope_method')
    path = path.remove('_collection_method')
    path = path.remove('_item_method')
    path = path.remove('_nil_method')

    value_for(object: object, path: path)
  end
end
