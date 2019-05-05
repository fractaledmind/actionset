# frozen_string_literal: true

module PathHelpers
  def all_possible_paths_for(type, options = {})
    association = 'only'
    computed_field = "computed_#{type}"
    computed_association = "computed_#{association}"

    [].tap do |paths|
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
  end

  def all_possible_path_combinations_for(type_1, type_2)
    all_possible_paths_for(type_1)
      .product(
        all_possible_paths_for(type_2)
      )
  end

  def value_for(object:, path:)
    ActiveSet::AttributeInstruction.new(path, nil).value_for(item: object)
  end
end
