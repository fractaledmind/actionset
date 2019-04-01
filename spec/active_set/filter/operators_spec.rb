# frozen_string_literal: true

require 'spec_helper'

INCLUSIVE_NONCOMPOUND_BINARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == false }
  .select { |k,v| v[:identity] == :inclusive }
EXCLUSIVE_NONCOMPOUND_BINARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == false }
  .select { |k,v| v[:identity] == :exclusive }
INCLUSIVE_COMPOUND_BINARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == true }
  .select { |k,v| v[:identity] == :inclusive }
EXCLUSIVE_COMPOUND_BINARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == true }
  .select { |k,v| v[:identity] == :exclusive }

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  describe '#filter' do
    ApplicationRecord::DB_FIELD_TYPES.each do |type|
      [1, 2].each do |id|
        INCLUSIVE_NONCOMPOUND_BINARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{schema[:alias]})
            only.#{type}(#{operator})
            only.#{type}(#{schema[:alias]})
          ].each do |path|
            it "{ #{path}: }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instruction_single_value = ActiveSet::AttributeInstruction.new(path, nil)
                                          .value_for(item: matching_item)
              instructions = {
                path => instruction_single_value
              }
              results = @active_set.filter(instructions)
              result_ids = results.map(&:id)

              expect(result_ids).to include matching_item.id
            end
          end
        end

        EXCLUSIVE_NONCOMPOUND_BINARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{schema[:alias]})
            only.#{type}(#{operator})
            only.#{type}(#{schema[:alias]})
          ].each do |path|
            it "{ #{path}: }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instruction_single_value = ActiveSet::AttributeInstruction.new(path, nil)
                                          .value_for(item: matching_item)
              instructions = {
                path => instruction_single_value
              }
              results = @active_set.filter(instructions)
              result_ids = results.map(&:id)

              expect(result_ids).not_to include matching_item.id
            end
          end
        end

        INCLUSIVE_COMPOUND_BINARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{schema[:alias]})
            only.#{type}(#{operator})
            only.#{type}(#{schema[:alias]})
          ].each do |path|
            it "{ #{path}: }" do
              matching_item = instance_variable_get("@thing_#{id}")
              other_thing = FactoryBot.build(:thing,
                              boolean: !matching_item.boolean,
                              only: FactoryBot.build(:only,
                                                    boolean: !matching_item.only.boolean))
              instruction_multi_value = [
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item),
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: other_thing)
              ]
              instructions = {
                path => instruction_multi_value
              }
              results = @active_set.filter(instructions)
              result_ids = results.map(&:id)

              expect(result_ids).to include matching_item.id
            end
          end
        end

        EXCLUSIVE_COMPOUND_BINARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{schema[:alias]})
            only.#{type}(#{operator})
            only.#{type}(#{schema[:alias]})
          ].each do |path|
            it "{ #{path}: }" do
              matching_item = instance_variable_get("@thing_#{id}")
              other_thing = FactoryBot.build(:thing,
                               boolean: !matching_item.boolean,
                               only: FactoryBot.build(:only,
                                                      boolean: !matching_item.only.boolean))
              instruction_multi_value = [
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: matching_item),
                ActiveSet::AttributeInstruction.new(path, nil).value_for(item: other_thing)
              ]
              instructions = {
                path => instruction_multi_value
              }
              results = @active_set.filter(instructions)
              result_ids = results.map(&:id)

              expect(result_ids).not_to include matching_item.id
            end
          end
        end

        # multi value mixed operators
        # TODO
      end
    end
  end
end
