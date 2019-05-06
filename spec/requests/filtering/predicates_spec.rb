# frozen_string_literal: true

require 'spec_helper'

# NOTE: This feature currently only works with ActiveRecord
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
      get things_path(format: :json),
          params: { filter: instructions }
    end

    ApplicationRecord::DB_FIELD_TYPES.each do |type|
      [[1, 2].sample].each do |id|
        # single value inclusive operators
        [%i[
          eq
          lteq
          gteq
          matches
        ].sample].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].sample do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instruction_single_value) do
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item)
              end
              let(:instructions) do
                {
                  path => instruction_single_value
                }
              end

              it { expect(result_ids).to include matching_item.id }
            end
          end
        end

        # single value exlusive operators
        [%i[
          not_eq
          lt
          gt
          does_not_match
        ].sample].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].sample do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instruction_single_value) do
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item)
              end
              let(:instructions) do
                {
                  path => instruction_single_value
                }
              end

              it { expect(result_ids).not_to include matching_item.id }
            end
          end
        end

        # multi value inclusive operators
        [%i[
          eq_any
          not_eq_any
          in
          in_any
          not_in_any
          lteq_any
          gteq_any
          matches_any
          does_not_match_any
        ].sample].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].sample do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:other_thing) do
                FactoryBot.build(:thing,
                                 boolean: !matching_item.boolean,
                                 only: FactoryBot.build(:only,
                                                        boolean: !matching_item.only.boolean))
              end
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

              it { expect(result_ids).to include matching_item.id }
            end
          end
        end

        # multi value exclusive operators
        [%i[
          eq_all
          not_eq_all
          not_in
          in_all
          not_in_all
          lt_all
          gt_all
          matches_all
          does_not_match_all
        ].sample].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].sample do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:other_thing) do
                FactoryBot.build(:thing,
                                 boolean: !matching_item.boolean,
                                 only: FactoryBot.build(:only,
                                                        boolean: !matching_item.only.boolean))
              end
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

              it { expect(result_ids).not_to include matching_item.id }
            end
          end
        end

        # multi value mixed operators
        # [%i[
        #   lt_any
        #   lteq_all
        #   gt_any
        #   gteq_all
        # ].sample].each do |operator|
        #   %W[
        #     #{type}(#{operator})
        #     only.#{type}(#{operator})
        #   ].sample do |path|
        #     context "{ #{path}: }" do
        #       let(:matching_item) { instance_variable_get("@thing_#{id}") }
        #       let(:other_thing) do
        #         FactoryBot.build(:thing,
        #                          boolean: !matching_item.boolean,
        #                          only: FactoryBot.build(:only,
        #                                                 boolean: !matching_item.only.boolean))
        #       end
        #       let(:instruction_multi_value) do
        #         [
        #           ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item),
        #           ActiveSet::AttributeInstruction.new(path, nil).value_for(item: other_thing)
        #         ]
        #       end
        #       let(:instructions) do
        #         {
        #           path => instruction_multi_value
        #         }
        #       end

        #       if type.presence_in(%i[binary datetime decimal float integer]) && operator == :gt_any
        #         it { expect(result_ids).not_to include matching_item.id }
        #       else
        #       end
        #     end
        #   end
        # end
      end
    end
  end
end
