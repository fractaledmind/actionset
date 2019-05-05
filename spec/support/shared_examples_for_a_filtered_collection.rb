# frozen_string_literal: true

RSpec.shared_examples 'a filtered collection' do
  it do
    expect(result.map(&:id)).to eq [matching_item.id]
  end
end
