# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing)
    @thing_2 = FactoryBot.create(:thing)
    @active_set = ActiveSet.new(Thing.all)
  end

  describe '#filter' do
    let(:result) { @active_set.filter(instructions) }

    all_possible_paths_for('invalid_field').each do |path|
      context "{ #{path}: }" do
        let(:instructions) do
          {
            path => filter_value_for(object: nil, path: path)
          }
        end

        it { expect(result.map(&:id)).to eq Thing.pluck(:id) }
      end
    end

    ApplicationRecord::FILTERABLE_TYPES.each do |type|
      [1, 2].each do |id|
        let(:matching_item) { instance_variable_get("@thing_#{id}") }

        all_possible_paths_for(type).each do |path|
          context "{ #{path}: }" do
            let(:instructions) do
              {
                path => filter_value_for(object: matching_item, path: path)
              }
            end

            it { expect(result.map(&:id)).to eq [matching_item.id] }
          end
        end
      end
    end

    ApplicationRecord::FILTERABLE_TYPES.combination(2).each do |type_1, type_2|
      [1, 2].each do |id|
        let(:matching_item) { instance_variable_get("@thing_#{id}") }

        all_possible_path_combinations_for(type_1, type_2).each do |path_1, path_2|
          context "{ #{path_1}:, #{path_2} }" do
            let(:instructions) do
              {
                path_1 => filter_value_for(object: matching_item, path: path_1),
                path_2 => filter_value_for(object: matching_item, path: path_2)
              }
            end

            it { expect(result.map(&:id)).to eq [matching_item.id] }
          end
        end
      end
    end
  end
end
