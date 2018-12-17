# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, one: FactoryBot.create(:one))
    @thing_2 = FactoryBot.create(:thing, one: FactoryBot.create(:one))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  describe '#filter' do
    let(:result) { @active_set.filter(instructions) }

    ApplicationRecord::FIELD_TYPES.each do |type|
      context "with #{type.upcase} type" do
        [1, 2].each do |id|
          context "matching @thing_#{id}" do
            let(:matching_item) { instance_variable_get("@thing_#{id}") }

            %W[
              #{type}
              computed_#{type}
              one.#{type}
              one.computed_#{type}
              computed_one.#{type}
              computed_one.computed_#{type}
            ].each do |path|
              context "{ #{path}: }" do
                let(:instructions) do
                  {
                    path => path.split('.').reduce(matching_item) { |obj, m| obj.send(m) }
                  }
                end

                it { expect(result.map(&:id)).to eq [matching_item.id] }
              end
            end
          end
        end
      end
    end

    ApplicationRecord::FIELD_TYPES.combination(2).each do |type_1, type_2|
      context "with #{type_1.upcase} and #{type_2.upcase} types" do
        [1, 2].each do |id|
          context "matching @thing_#{id}" do
            let(:matching_item) { instance_variable_get("@thing_#{id}") }

            %W[
              #{type_1}
              #{type_2}
              computed_#{type_1}
              computed_#{type_2}
              one.#{type_1}
              one.#{type_2}
              one.computed_#{type_1}
              one.computed_#{type_2}
              computed_one.#{type_1}
              computed_one.#{type_2}
              computed_one.computed_#{type_1}
              computed_one.computed_#{type_2}
            ].combination(2).each do |path_1, path_2|
              context "{ #{path_1}:, #{path_2} }" do
                let(:instructions) do
                  {
                    path_1 => path_1.split('.').reduce(matching_item) { |obj, m| obj.send(m) },
                    path_2 => path_2.split('.').reduce(matching_item) { |obj, m| obj.send(m) }
                  }
                end

                it { expect(result.map(&:id)).to eq [matching_item.id] }
              end
            end
          end
        end
      end
    end
  end
end
