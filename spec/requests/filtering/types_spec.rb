# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /things?filter', type: :request do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end

  context '.json' do
    let(:results) { JSON.parse(response.body) }
    let(:result_ids) { results.map { |f| f['id'] } }

    before(:each) do
      allow_any_instance_of(ThingsController)
        .to receive(:filter_set_types)
        .and_return({
          types: instructions.transform_values(&:class)
        }) if defined?(filter_set_types)
      get things_path(format: :json),
          params: { filter: instructions }
    end

    ApplicationRecord::FIELD_TYPES.each do |type|
      [1, 2].each do |id|
        let(:matching_item) { instance_variable_get("@thing_#{id}") }

        all_possible_paths_for(type).each do |path|
          context "{ #{path}: }" do
            let(:instructions) do
              {
                path => filter_value_for(object: matching_item, path: path)
              }
            end

            it { expect(result_ids).to eq [matching_item.id] }
          end

          context "{ #{path}: } #filter_set_types" do
            let(:filter_set_types) { true }
            let(:instructions) do
              {
                path => filter_value_for(object: matching_item, path: path)
              }
            end

            it { expect(result_ids).to eq [matching_item.id] }
          end

          context "{ 0: { attribute: #{path} } }" do
            let(:instructions) do
              {
                '0': {
                  attribute: path,
                  operator: 'EQ',
                  query: filter_value_for(object: matching_item, path: path)
                }
              }
            end

            it { expect(result_ids).to eq [matching_item.id] }
          end

          context "{ { attribute: #{path} } }" do
            let(:instructions) do
              {
                attribute: path,
                operator: 'EQ',
                query: filter_value_for(object: matching_item, path: path)
              }
            end

            it { expect(result_ids).to eq [matching_item.id] }
          end
        end
      end
    end

    ApplicationRecord::FIELD_TYPES.combination(2).each do |type_1, type_2|
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

            it { expect(result_ids).to eq [matching_item.id] }
          end

          context "{ #{path_1}:, #{path_2} } #filter_set_types" do
            let(:filter_set_types) { true }
            let(:instructions) do
              {
                path_1 => filter_value_for(object: matching_item, path: path_1),
                path_2 => filter_value_for(object: matching_item, path: path_2)
              }
            end

            it { expect(result_ids).to eq [matching_item.id] }
          end

          context "{ 0: { attribute: #{path_1} }, 1: { attribute: #{path_2} } }" do
            let(:instructions) do
              {
                '0': {
                  attribute: path_1,
                  operator: 'EQ',
                  query: filter_value_for(object: matching_item, path: path_1)
                },
                '1': {
                  attribute: path_2,
                  operator: 'EQ',
                  query: filter_value_for(object: matching_item, path: path_2)
                }
              }
            end

            it { expect(result_ids).to eq [matching_item.id] }
          end
        end
      end
    end
  end
end
