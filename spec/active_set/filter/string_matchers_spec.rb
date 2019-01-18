# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  describe '#filter' do
    let(:results) { @active_set.filter(instructions) }
    let(:result_ids) { results.map(&:id) }

    ApplicationRecord::DB_FIELD_TYPES.each do |type|
      [1, 2].each do |id|
        # single value inclusive operators
        %i[
          start
          ~^
          end
          ~$
          contain
          ~*
        ].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].each do |path|
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
        %i[
          not_start
          !^
          not_end
          !$
          not_contain
          !*
        ].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].each do |path|
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
        %i[
          start_any
          E~^
          not_start_any
          E!^
          end_any
          E~$
          not_end_any
          E!$
          contain_any
          E~*
          not_contain_any
          E!*
        ].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].each do |path|
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
        %i[
          start_all
          A~^
          not_start_all
          A!^
          end_all
          A~$
          not_end_all
          A!$
          contain_all
          A~*
          not_contain_all
          A!*
        ].each do |operator|
          %W[
            #{type}(#{operator})
            only.#{type}(#{operator})
          ].each do |path|
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
      end
    end
  end
end
