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

    ApplicationRecord::DB_FIELD_TYPES.each do |type|
      [1, 2].each do |id|
        let(:matching_item) { instance_variable_get("@thing_#{id}") }

        all_possible_scope_paths_for(type).each do |path|
          context "{ #{path}: }" do
            let(:instructions) do
              {
                path => filter_value_for(object: matching_item, path: path)
              }
            end

            if path.end_with?('_collection_method') || path.end_with?('_scope_method')
              if path.include?('computed_')
                it { expect(result.map(&:id)).to eq [] }
              else
                it { expect(result.map(&:id)).to eq [matching_item.id] }
              end
            else
              it { expect(result.map(&:id)).to eq Thing.pluck(:id) }
            end
          end
        end
      end
    end
  end
end
