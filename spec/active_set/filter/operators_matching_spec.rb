# frozen_string_literal: true

require 'spec_helper'

MATCHING_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::MATCHING_OPERATORS
INCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select do |o|
    o[:type] == :binary &&
    o[:compound] == false &&
    o[:matching_behavior] == :inclusive
  end
EXCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select do |o|
    o[:type] == :binary &&
    o[:compound] == false &&
    o[:matching_behavior] == :exclusive
  end
INCLUSIVE_COMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select do |o|
    o[:type] == :binary &&
    o[:compound] == true &&
    o[:matching_behavior] == :inclusive
  end
EXCLUSIVE_COMPOUND_MATCHING_OPERATORS = MATCHING_OPERATORS
  .select do |o|
    o[:type] == :binary &&
    o[:compound] == true &&
    o[:matching_behavior] == :exclusive
  end

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  describe '#filter' do
    %i[string text binary].each do |type|
      [1, 2].each do |id|
        INCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS.each do |schema|
          %W[
            #{type}(#{schema[:name]})
            #{type}(#{schema[:name]})/i/
            #{type}(#{schema[:shorthand]})
            #{type}(#{schema[:shorthand]})/i/
            only.#{type}(#{schema[:name]})
            only.#{type}(#{schema[:name]})/i/
            only.#{type}(#{schema[:shorthand]})
            only.#{type}(#{schema[:shorthand]})/i/
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

        EXCLUSIVE_NONCOMPOUND_MATCHING_OPERATORS.each do |schema|
          %W[
            #{type}(#{schema[:name]})
            #{type}(#{schema[:name]})/i/
            #{type}(#{schema[:shorthand]})
            #{type}(#{schema[:shorthand]})/i/
            only.#{type}(#{schema[:name]})
            only.#{type}(#{schema[:name]})/i/
            only.#{type}(#{schema[:shorthand]})
            only.#{type}(#{schema[:shorthand]})/i/
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

        INCLUSIVE_COMPOUND_MATCHING_OPERATORS.each do |schema|
          %W[
            #{type}(#{schema[:name]})
            #{type}(#{schema[:name]})/i/
            #{type}(#{schema[:shorthand]})
            #{type}(#{schema[:shorthand]})/i/
            only.#{type}(#{schema[:name]})
            only.#{type}(#{schema[:name]})/i/
            only.#{type}(#{schema[:shorthand]})
            only.#{type}(#{schema[:shorthand]})/i/
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

        EXCLUSIVE_COMPOUND_MATCHING_OPERATORS.each do |schema|
          %W[
            #{type}(#{schema[:name]})
            #{type}(#{schema[:name]})/i/
            #{type}(#{schema[:shorthand]})
            #{type}(#{schema[:shorthand]})/i/
            only.#{type}(#{schema[:name]})
            only.#{type}(#{schema[:name]})/i/
            only.#{type}(#{schema[:shorthand]})
            only.#{type}(#{schema[:shorthand]})/i/
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
