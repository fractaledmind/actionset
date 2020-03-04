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
      [1, 2].each do |id|
        inclusive_unary_operators.each do |operator|
          all_possible_type_operator_paths_for(type, operator).each do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instruction_single_value) do
                    value_for(object: matching_item, path: path)
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

        exclusive_unary_operators.each do |operator|
          all_possible_type_operator_paths_for(type, operator).each do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instruction_single_value) do
                    value_for(object: matching_item, path: path)
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

        inconclusive_unary_operators.each do |operator|
          all_possible_type_operator_paths_for(type, operator).each do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instruction_single_value) do
                value_for(object: matching_item, path: path)
              end
              let(:instructions) do
                {
                  path => instruction_single_value
                }
              end

              # By default, we expect these operators to return nothing.
              # If, however, they do return something, we guarantee it is a logical result
              it do
                set_instruction = ActiveSet::Filtering::Enumerable::SetInstruction
                  .new(
                    ActiveSet::AttributeInstruction.new(path, instruction_single_value),
                    @active_set.set)
                result_objs = Thing.where(id: result_ids)

                expect(result_objs.map { |obj| set_instruction.item_matches_query?(obj) })
                  .to all( be true )
              end
            end
          end
        end

        inclusive_binary_operators.each do |operator|
          all_possible_type_operator_paths_for(type, operator).each do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:other_thing) do
                guaranteed_unique_object_for(matching_item,
                                             only: guaranteed_unique_object_for(matching_item.only))
              end
              let(:matching_value) { value_for(object: matching_item, path: path) }
              let(:other_value) { value_for(object: other_thing, path: path) }
              let(:instruction_multi_value) do
                if operator.to_s.split('_').include?('IN') && (operator.to_s.split('_') & %w[ANY ALL]).any?
                  [ [matching_value], [other_value] ]
                else
                  [ matching_value, other_value ]
                end
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

        exclusive_binary_operators.each do |operator|
          all_possible_type_operator_paths_for(type, operator).each do |path|
            context "{ #{path}: }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:other_thing) do
                guaranteed_unique_object_for(matching_item,
                                             only: guaranteed_unique_object_for(matching_item.only))
              end
              let(:matching_value) { value_for(object: matching_item, path: path) }
              let(:other_value) { value_for(object: other_thing, path: path) }
              let(:instruction_multi_value) do
                if operator.to_s.split('_').include?('IN') && (operator.to_s.split('_') & %w[ANY ALL]).any?
                  [ [matching_value], [other_value] ]
                else
                  [ matching_value, other_value ]
                end
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

        inconclusive_binary_operators.each do |operator|
          all_possible_type_operator_paths_for(type, operator).each do |path|
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
                  value_for(object: matching_item, path: path),
                  value_for(object: other_thing, path: path)
                ]
              end
              let(:instructions) do
                {
                  path => instruction_multi_value
                }
              end

              # By default, we expect these operators to return nothing.
              # If, however, they do return something, we guarantee it is a logical result
              it do
                set_instruction = ActiveSet::Filtering::Enumerable::SetInstruction
                  .new(
                    ActiveSet::AttributeInstruction.new(path, instruction_multi_value),
                    @active_set.set)
                result_objs = Thing.where(id: result_ids)

                expect(result_objs.map { |obj| set_instruction.item_matches_query?(obj) })
                  .to all( be true )
              end
            end
          end
        end
      end
    end
  end
end
