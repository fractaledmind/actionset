# frozen_string_literal: true

require 'spec_helper'

INCLUSIVE_UNARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :unary }
  .select { |k,v| v[:identity] == :inclusive }
EXCLUSIVE_UNARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :unary }
  .select { |k,v| v[:identity] == :exclusive }
INCONCLUSIVE_UNARY_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::OPERATORS
  .select { |k,v| v[:type] == :unary }
  .select { |k,v| v[:identity] == :inconclusive }

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
        INCLUSIVE_UNARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}/p/
            only.#{type}/p/
          ].each do |path|
            it "{ #{path}: #{operator} }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instructions = {
                path => operator
              }
              results = @active_set.filter(instructions)
              result_ids = results.map(&:id)

              if !schema.key?(:allowed_for)
                expect(result_ids).to include matching_item.id
              elsif schema.key?(:allowed_for) && schema[:allowed_for].include?(type.to_sym)
                expect(result_ids).to include matching_item.id
              else
                expect(result_ids).to be_empty
              end
            end
          end
        end

        EXCLUSIVE_UNARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}/p/
            only.#{type}/p/
          ].each do |path|
            it "{ #{path}: #{operator} }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instructions = {
                path => operator
              }
              results = @active_set.filter(instructions)
              result_ids = results.map(&:id)

              expect(result_ids).not_to include matching_item.id
              if !schema.key?(:allowed_for)
                expect(result_ids).not_to include matching_item.id
              elsif schema.key?(:allowed_for) && schema[:allowed_for].include?(type.to_sym)
                expect(result_ids).not_to include matching_item.id
              else
                expect(result_ids).to be_empty
              end
            end
          end
        end

        INCONCLUSIVE_UNARY_OPERATORS.each do |operator, schema|
          %W[
            #{type}/p/
            only.#{type}/p/
          ].each do |path|
            it "{ #{path}: #{operator} }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instructions = {
                path => operator
              }
              results = @active_set.filter(instructions)
              result_values = results.map { |item| ActiveSet::AttributeInstruction.new(path, nil).value_for(item: item) }
              expected_boolean = %i[is_true not_false].include? operator

              if !schema.key?(:allowed_for)
                expect(result_values).to all(be expected_boolean)
              elsif schema.key?(:allowed_for) && schema[:allowed_for].include?(type.to_sym)
                expect(result_values).to all(be expected_boolean)
              end
            end
          end
        end
      end
    end
  end
end
