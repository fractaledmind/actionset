# frozen_string_literal: true

require 'spec_helper'

# NOTE: This feature currently only works with ActiveRecord
RSpec.describe 'GET /things?filter', type: :request do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  context '.json' do
    let(:results) { JSON.parse(response.body) }
    let(:result_ids) { results.map { |f| f['id'] } }
    let(:other_thing) do
      FactoryBot.build(:thing,
                       boolean: !matching_item.boolean,
                       only: FactoryBot.build(:only,
                                              boolean: !matching_item.only.boolean))
    end

    def expected_result_ids(keypath, item, type, operator, value)
      model_class = ActiveSet::AttributeInstruction.new(keypath, nil)
                      .resource_for(item: item)
                      .class
      relation = model_class.where(
        model_class.arel_table[type]
                   .public_send(
                     operator,
                     value)
      )

      relation.pluck(:id)
    end

    before(:each) do
      get things_path(format: :json),
          params: { filter: instructions }
    end

    (ApplicationRecord::FIELD_TYPES - %i[symbol bignum]).each do |type|
      [1, 2].each do |id|
        let(:matching_item) { instance_variable_get("@thing_#{id}") }

        # single value operators
        %i[
          eq
          not_eq
          lt
          lteq
          gt
          gteq
          matches
          does_not_match
        ].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].each do |path|
            context "{ #{path}: }" do
              let(:instruction_single_value) do
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item)
              end
              let(:instructions) do
                {
                  path => instruction_single_value
                }
              end

              it { expect(result_ids).to eq expected_result_ids(path, matching_item, type, operator, instruction_single_value) }
            end
          end
        end

        # multi value operators
        %i[
          eq_any
          not_eq_any
          eq_all
          not_eq_all
          in
          not_in
          in_any
          not_in_any
          in_all
          not_in_all
          lt_any
          lteq_any
          lt_all
          lteq_all
          gt_any
          gteq_any
          gt_all
          gteq_all
          matches_any
          does_not_match_any
          matches_all
          does_not_match_all
        ].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].each do |path|
            context "{ #{path}: }" do
              let(:instruction_multi_value) do
                [
                  ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item),
                  ActiveSet::AttributeInstruction.new(path, nil).value_for(item: other_thing)
                ]
              end
              let(:instructions) do
                {
                  path => instruction_multi_value
                }
              end

              it { expect(result_ids).to eq expected_result_ids(path, matching_item, type, operator, instruction_multi_value) }
            end
          end
        end
      end
    end
  end
end
