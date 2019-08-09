# frozen_string_literal: true

module PathHelpers
  def relevant_paths_for_testing_given_environment(paths_for_test)
    if ENV['LOGICALLY_EXHAUSTIVE_REQUEST_SPECS'] == 'true'
      paths_for_test
    else
      [paths_for_test.sample]
    end
  end

  def all_possible_paths_for(type, options = {})
    association = 'only'
    computed_field = "computed_#{type}"
    computed_association = "computed_#{association}"

    paths_for_test = [].tap do |paths|
      paths << type
      paths << computed_field unless options[:computed_fields] == false
      unless options[:associations] == false
        paths << [association, type].join('.')
        paths << [association, computed_field].join('.') unless options[:computed_fields] == false
      end
      unless options[:computed_associations] == false
        paths << [computed_association, type].join('.')
        paths << [computed_association, computed_field].join('.') unless options[:computed_fields] == false
      end
    end

    relevant_paths_for_testing_given_environment(paths_for_test)
  end

  def all_possible_path_combinations_for(type_1, type_2)
    paths_for_test = all_possible_paths_for(type_1)
                     .product(
                       all_possible_paths_for(type_2)
                     )
    relevant_paths_for_testing_given_environment(paths_for_test)
  end

  def value_for(object:, path:)
    ActiveSet::AttributeInstruction.new(path, nil).value_for(item: object)
  end
end
