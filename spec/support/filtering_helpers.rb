# frozen_string_literal: true

module FilteringHelpers
  PREDICATE_OPERATORS = ActiveSet::Filtering::Constants::PREDICATES
  INCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == false &&
    o[:behavior] == :inclusive
  end.map(&:first)
  EXCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == false &&
    o[:behavior] == :exclusive
  end.map(&:first)
  INCLUSIVE_BINARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == true &&
    o[:behavior] == :inclusive
  end.map(&:first)
  EXCLUSIVE_BINARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == true &&
    o[:behavior] == :exclusive
  end.map(&:first)
  INCONCLUSIVE_BINARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == true &&
    o[:behavior] == :inconclusive
  end.map(&:first)

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

    value = value_for(object: object, path: path)
    return value&.upcase if path.end_with? '/i/'

    value
  end
end
