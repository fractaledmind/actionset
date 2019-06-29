# frozen_string_literal: true

require 'spec_helper'

# PREDICATE_OPERATORS = ActiveSet::Filtering::ActiveRecord::Constants::PREDICATE_OPERATORS
# INCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS
#   .select do |o|
#     o[:type] == :unary &&
#     o[:matching_behavior] == :inclusive
#   end
# EXCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS
#   .select do |o|
#     o[:type] == :unary &&
#     o[:matching_behavior] == :exclusive
#   end
# INCONCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS
#   .select do |o|
#     o[:type] == :unary &&
#     o[:matching_behavior] == :inconclusive
#   end


RSpec.describe ActiveSet do
  PREDICATE_OPERATORS = ActiveSet::Filtering::Constants::BASE_PREDICATES
  INCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == false &&
    o[:behavior] == :inclusive
  end.map(&:first)
  EXCLUSIVE_UNARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == false &&
    o[:behavior] == :exclusive
  end.map(&:first)
  INCLUSIVE_BINARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == true &&
    o[:behavior] == :inclusive
  end.map(&:first)
  EXCLUSIVE_BINARY_OPERATORS = PREDICATE_OPERATORS.select do |_, o|
    o[:compound] == true &&
    o[:behavior] == :exclusive
  end.map(&:first)

  before(:all) do
    @thing_1 = FactoryBot.create(:thing)
    @thing_2 = FactoryBot.create(:thing)
  end

  describe '#filter' do
    ['itself', 'to_a'].each do |relation_mutator|
      context "/#{ relation_mutator == 'itself' ? 'ActiveRecord' : 'Enumberable' }/" do
        before(:all) do
          @active_set = ActiveSet.new(Thing.all.public_send(relation_mutator))
        end
        let(:results) { @active_set.filter(instructions) }
        let(:result_ids) { results.map(&:id) }

        ApplicationRecord::DB_FIELD_TYPES.each do |type|
          [1, 2].each do |id|
            INCLUSIVE_UNARY_OPERATORS.each do |operator|
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

            EXCLUSIVE_UNARY_OPERATORS.each do |operator|
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

            INCLUSIVE_BINARY_OPERATORS.each do |operator|
              %W[
                #{type}(#{operator})
                only.#{type}(#{operator})
              ].each do |path|
                context "{ #{path}: }" do
                  let(:matching_item) { instance_variable_get("@thing_#{id}") }
                  let(:other_thing) do
                    guaranteed_unique_object_for(matching_item,
                                                 only: guaranteed_unique_object_for(matching_item.only))
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

            EXCLUSIVE_BINARY_OPERATORS.each do |operator|
              %W[
                #{type}(#{operator})
                only.#{type}(#{operator})
              ].each do |path|
                context "{ #{path}: }" do
                  let(:matching_item) { instance_variable_get("@thing_#{id}") }
                  let(:other_thing) do
                    guaranteed_unique_object_for(matching_item,
                                                 only: guaranteed_unique_object_for(matching_item.only))
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
            # %i[
            #   lt_any
            #   lteq_all
            #   gt_any
            #   gteq_all
            # ].each do |operator|
            #   %W[
            #     #{type}(#{operator})
            #     only.#{type}(#{operator})
            #   ].each do |path|
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
  end
end
