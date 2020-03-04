# frozen_string_literal: true

module FilteringHelpers
  PREDICATE_OPERATORS = ActiveSet::Filtering::Constants::PREDICATES

  def inclusive_unary_operators
    operators_for_test = PREDICATE_OPERATORS.select do |_, o|
      o[:compound] == false &&
      o[:behavior] == :inclusive
    end.map(&:first)

    relevant_paths_for_testing_given_environment(operators_for_test)
  end

  def exclusive_unary_operators
    operators_for_test = PREDICATE_OPERATORS.select do |_, o|
      o[:compound] == false &&
      o[:behavior] == :exclusive
    end.map(&:first)

    relevant_paths_for_testing_given_environment(operators_for_test)
  end

  def inconclusive_unary_operators
    operators_for_test = PREDICATE_OPERATORS.select do |_, o|
      o[:compound] == false &&
      o[:behavior] == :inconclusive
    end.map(&:first)

    relevant_paths_for_testing_given_environment(operators_for_test)
  end

  def inclusive_binary_operators
    operators_for_test = PREDICATE_OPERATORS.select do |_, o|
      o[:compound] == true &&
      o[:behavior] == :inclusive
    end.map(&:first)

    relevant_paths_for_testing_given_environment(operators_for_test)
  end

  def exclusive_binary_operators
    operators_for_test = PREDICATE_OPERATORS.select do |_, o|
      o[:compound] == true &&
      o[:behavior] == :exclusive
    end.map(&:first)

    relevant_paths_for_testing_given_environment(operators_for_test)
  end

  def inconclusive_binary_operators
    operators_for_test = PREDICATE_OPERATORS.select do |_, o|
      o[:compound] == true &&
      o[:behavior] == :inconclusive
    end.map(&:first)

    relevant_paths_for_testing_given_environment(operators_for_test)
  end

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

  def all_possible_type_operator_paths_for(type, operator)
    paths_for_test = %W[
      #{type}(#{operator})
      only.#{type}(#{operator})
    ]
    relevant_paths_for_testing_given_environment(paths_for_test)
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
