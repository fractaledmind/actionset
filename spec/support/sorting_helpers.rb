# frozen_string_literal: true

module SortingHelpers
  def all_possible_sort_instructions_for(type)
    paths_for_test = all_possible_paths_for(type)
      .product([:asc, 'desc'])
      .map { |instruction_tuple| Hash[*instruction_tuple] }

    relevant_paths_for_testing_given_environment(paths_for_test)
  end

  def all_possible_sort_instruction_combinations_for(type_1, type_2)
    paths_for_test = all_possible_path_combinations_for(type_1, type_2)
      .to_enum
      .with_index
      .map do |paths, index|
        directions = index.odd? ? ['asc', :desc] : [:desc, 'asc']
        Hash[paths.zip(directions)]
      end

    relevant_paths_for_testing_given_environment(paths_for_test)
  end

  def sort_value_for(object:, path:)
    value = value_for(object: object, path: path)
    return value.to_s if [true, false].include? value
    return value&.upcase if path.end_with? '/i/'

    value
  end
end
