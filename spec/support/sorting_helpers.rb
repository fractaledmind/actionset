# frozen_string_literal: true

module SortingHelpers
  def all_possible_sort_instructions_for(type)
    all_possible_paths_for(type)
      .product([:asc, 'desc'])
      .map { |instruction_tuple| Hash[*instruction_tuple] }
  end

  def all_possible_sort_instruction_combinations_for(type_1, type_2)
    all_possible_path_combinations_for(type_1, type_2)
      .to_enum
      .with_index
      .map do |paths, index|
        directions = index.odd? ? ['asc', :desc] : [:desc, 'asc']
        Hash[paths.zip(directions)]
      end
  end

  def sort_value_for(object:, path:)
    value = value_for(object: object, path: path)
    return value.to_s if [true, false].include? value
    return value&.downcase if path.end_with? '(i)'

    value
  end
end
