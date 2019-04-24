# frozen_string_literal: true

require 'spec_helper'

TIME_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::TIME_OPERATORS
INCLUSIVE_TIME_OPERATORS = TIME_OPERATORS
  .select do |o|
    o[:type] == :unary &&
    o[:matching_behavior] == :inclusive
  end
EXCLUSIVE_TIME_OPERATORS = TIME_OPERATORS
  .select do |o|
    o[:type] == :unary &&
    o[:matching_behavior] == :exclusive
  end
INCONCLUSIVE_TIME_OPERATORS = TIME_OPERATORS
  .select do |o|
    o[:type] == :unary &&
    o[:matching_behavior] == :inconclusive
  end

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  describe '#filter' do
    %i[time datetime].each do |type|
      [1, 2].each do |id|
        INCONCLUSIVE_TIME_OPERATORS.each do |schema|
          %W[
            #{type}/p/
            only.#{type}/p/
          ].each do |path|
            it "{ #{path}: #{schema[:name]} }" do
              matching_item = instance_variable_get("@thing_#{id}")
              instructions = {
                path => schema[:name]
              }
              results = @active_set.filter(instructions)
              result_values = results.map { |item| ActiveSet::AttributeInstruction.new(path, nil).value_for(item: item) }
p result_values
              expected_boolean = nil

              if !schema.key?(:allowed_for)
                expect(result_values).to all(be expected_boolean)
              elsif schema.key?(:allowed_for) && schema[:allowed_for].include?(type.to_sym)
                expect(result_values).to all(be expected_boolean)
              else
                expect(result_values).to all(be expected_boolean)
              end
            end
          end
        end

        # EXCLUSIVE_TIME_OPERATORS.each do |schema|
        #   %W[
        #     #{type}(#{schema[:name]})
        #     #{type}(#{schema[:alias]})
        #     only.#{type}(#{schema[:name]})
        #     only.#{type}(#{schema[:alias]})
        #   ].each do |path|
        #     it "{ #{path}: }" do
        #       matching_item = instance_variable_get("@thing_#{id}")
        #       instruction_value = ActiveSet::AttributeInstruction.new(path, nil)
        #                             .value_for(item: matching_item)
        #       instruction_value = type == :string ? instruction_value.upcase : instruction_value
        #       instructions = {
        #         path => instruction_value
        #       }
        #       results = @active_set.filter(instructions)

        #       expect(results.map(&:id))
        #         .not_to include instance_variable_get("@thing_#{id}").id
        #     end
        #   end
        # end
      end
    end
  end
end
