# frozen_string_literal: true

require 'spec_helper'

MATCHING_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:operator].to_s.include? 'match' }
INCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == false }
  .select { |k,v| v[:identity] == :inclusive }
EXCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == false }
  .select { |k,v| v[:identity] == :exclusive }
INCLUSIVE_COMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select { |k,v| v[:type] == :binary }
  .select { |k,v| v[:compound] == true }
  .select { |k,v| v[:identity] == :inclusive }
EXCLUSIVE_COMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
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
        INCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{operator})/i/
            #{type}(#{schema[:alias]})
            #{type}(#{schema[:alias]})/i/
            only.#{type}(#{operator})
            only.#{type}(#{operator})/i/
            only.#{type}(#{schema[:alias]})
            only.#{type}(#{schema[:alias]})/i/
          ].each do |path|
            it "{ #{path}: }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instruction_value = ActiveSet::AttributeInstruction.new(path, nil)
                                    .value_for(item: matching_item)
              instruction_value = type == :string ? instruction_value.upcase : instruction_value
              instructions = {
                path => instruction_value
              }
              results = @active_set.filter(instructions)

              expect(results.map(&:id))
                .to include matching_item.id
            end
          end
        end

        EXCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{operator})/i/
            #{type}(#{schema[:alias]})
            #{type}(#{schema[:alias]})/i/
            only.#{type}(#{operator})
            only.#{type}(#{operator})/i/
            only.#{type}(#{schema[:alias]})
            only.#{type}(#{schema[:alias]})/i/
          ].each do |path|
            it "{ #{path}: }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instruction_value = ActiveSet::AttributeInstruction.new(path, nil)
                                    .value_for(item: matching_item)
              instruction_value = type == :string ? instruction_value.upcase : instruction_value
              instructions = {
                path => instruction_value
              }
              results = @active_set.filter(instructions)

              expect(results.map(&:id))
                .not_to include instance_variable_get("@thing_#{id}").id
            end
          end
        end

        INCLUSIVE_COMPOUND_MATCHING_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{operator})/i/
            #{type}(#{schema[:alias]})
            #{type}(#{schema[:alias]})/i/
            only.#{type}(#{operator})
            only.#{type}(#{operator})/i/
            only.#{type}(#{schema[:alias]})
            only.#{type}(#{schema[:alias]})/i/
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

              expect(results.map(&:id))
                .to include matching_item.id
            end
          end
        end

        EXCLUSIVE_COMPOUND_MATCHING_OPERATORS.each do |operator, schema|
          %W[
            #{type}(#{operator})
            #{type}(#{operator})/i/
            #{type}(#{schema[:alias]})
            #{type}(#{schema[:alias]})/i/
            only.#{type}(#{operator})
            only.#{type}(#{operator})/i/
            only.#{type}(#{schema[:alias]})
            only.#{type}(#{schema[:alias]})/i/
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

              expect(results.map(&:id))
                .not_to include matching_item.id
            end
          end
        end
      end
    end
  end
end
