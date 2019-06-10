# frozen_string_literal: true

RSpec.shared_examples 'a sorted collection' do |instructions|
  it do
    result.each_cons(2) do |left_result, right_result|
      instructions.each do |(path, dir)|
        left_value = sort_value_for(path: path, object: left_result)
        right_value = sort_value_for(path: path, object: right_result)

        if (dir.to_s == 'asc')
          if (ActiveSet.configuration.on_asc_sort_nils_come == :last)
            expect(right_value).to (be >= left_value).or be_nil
          else
            expect(left_value).to (be <= right_value).or be_nil
          end
        elsif (dir.to_s == 'desc')
          if (ActiveSet.configuration.on_asc_sort_nils_come == :last)
            expect(left_value).to (be >= left_value).or be_nil
          else
            expect(right_value).to (be <= left_value).or be_nil
          end
        end
        break unless left_value == right_value
      end
    end
  end
end
