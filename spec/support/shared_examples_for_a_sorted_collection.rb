# frozen_string_literal: true

RSpec.shared_examples 'a sorted collection' do |instructions|
  it do
    result.each_cons(2) do |left_result, right_result|
      instructions.each do |(path, dir)|
        left_value = sort_value_for(path: path, object: left_result)
        right_value = sort_value_for(path: path, object: right_result)
        sortedness = dir.to_s == 'asc' ? -1 : 1

        expect(left_value <=> right_value).to satisfy { |v| [0, nil, sortedness].include? v }
        break unless left_value == right_value
      end
    end
  end
end
