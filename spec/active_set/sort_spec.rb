# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, string: 'a', integer: 1, boolean: true,
                                     date: 1.day.from_now.to_date, datetime: 1.day.from_now.to_datetime,
                                     decimal: 1.1, float: 1.1, time: 1.hour.from_now.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'ra', integer: 9))
    @thing_2 = FactoryBot.create(:thing, string: 'a', integer: 2, boolean: true,
                                     date: 1.day.ago.to_date, datetime: 1.day.ago.to_datetime,
                                     decimal: 2.2, float: 2.2, time: 2.hours.from_now.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'ra', integer: 8))
    @thing_3 = FactoryBot.create(:thing, string: 'z', integer: 1, boolean: true,
                                     date: 1.day.from_now.to_date, datetime: 1.day.from_now.to_datetime,
                                     decimal: 1.1, float: 1.1, time: 1.hour.ago.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'rz', integer: 9))
    @thing_4 = FactoryBot.create(:thing, string: 'z', integer: 2, boolean: true,
                                     date: 1.day.ago.to_date, datetime: 1.day.ago.to_datetime,
                                     decimal: 2.2, float: 2.2, time: 2.hours.ago.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'rz', integer: 8))
    @thing_5 = FactoryBot.create(:thing, string: 'A', integer: 1, boolean: false,
                                     date: 1.week.from_now.to_date, datetime: 1.week.from_now.to_datetime,
                                     decimal: 1.1, float: 1.1, time: 1.hour.from_now.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'rA', integer: 9))
    @thing_6 = FactoryBot.create(:thing, string: 'A', integer: 2, boolean: false,
                                     date: 1.week.ago.to_date, datetime: 1.week.ago.to_datetime,
                                     decimal: 2.2, float: 2.2, time: 2.hours.from_now.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'rA', integer: 8))
    @thing_7 = FactoryBot.create(:thing, string: 'Z', integer: 1, boolean: false,
                                     date: 1.week.from_now.to_date, datetime: 1.week.from_now.to_datetime,
                                     decimal: 1.1, float: 1.1, time: 1.hour.ago.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'rZ', integer: 9))
    @thing_8 = FactoryBot.create(:thing, string: 'Z', integer: 2, boolean: false,
                                     date: 1.week.ago.to_date, datetime: 1.week.ago.to_datetime,
                                     decimal: 2.2, float: 2.2, time: 2.hours.ago.to_time.to_s[12..-1],
                                     one: FactoryBot.create(:one, string: 'rZ', integer: 8))
    @active_set = ActiveSet.new(Thing.all)
    @all_things = Thing.all.to_a
  end
  after(:all) { Thing.delete_all }

  def value_for(path:, object:)
    value = path.split('.').reduce(object) { |obj, m| obj.send(m.gsub('(i)', '')) }
    return value.to_s if [true, false].include? value
    return value.downcase if path.end_with? '(i)'

    value
  end

  describe '#sort' do
    let(:result) { @active_set.sort(instructions) }

    ApplicationRecord::FIELD_TYPES.each do |type|
      context "with #{type.upcase} type" do
        [:asc, 'desc'].each do |direction|
          context "in #{direction} direction" do
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
                    path => direction
                  }
                end

                it do
                  result.each_cons(2) do |left_result, right_result|
                    left_value = value_for(path: path, object: left_result)
                    right_value = value_for(path: path, object: right_result)
                    operator = direction == :asc ? '<=' : '>='

                    expect(left_value).to be.send(operator, right_value)
                  end
                end
              end
            end
          end
        end
      end
    end

    ApplicationRecord::FIELD_TYPES.combination(2).each do |type_1, type_2|
      context "with #{type_1.upcase} and #{type_2.upcase} types" do
        paths = %W[
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
        ]
        all_possible_instructions = paths
                                    .combination(2)
                                    .flat_map do |path_1, path_2|
          [:asc, 'desc']
            .repeated_permutation(2)
            .map do |pair|
              Hash[[path_1, path_2].zip(pair)]
            end
        end

        all_possible_instructions.each do |instructions|
          context "{ #{instructions} }" do
            let(:instructions) { instructions }

            it do
              result.each_cons(2) do |left_result, right_result|
                (path_1, path_2) = instructions.keys
                (dir_1, dir_2) = instructions.values

                left_value_1 = value_for(path: path_1, object: left_result)
                right_value_1 = value_for(path: path_1, object: right_result)
                operator_1 = dir_1 == :asc ? '<=' : '>='

                expect(left_value_1).to be.send(operator_1, right_value_1)

                next unless left_value_1 == right_value_1

                left_value_2 = value_for(path: path_2, object: left_result)
                right_value_2 = value_for(path: path_2, object: right_result)
                operator_2 = dir_2 == :asc ? '<=' : '>='

                expect(left_value_2).to be.send(operator_2, right_value_2)
              end
            end
          end
        end
      end
    end

    context 'with STRING case-insensitive type' do
      [:asc, 'desc'].each do |direction|
        context "in #{direction} direction" do
          %w[
            string(i)
            computed_string(i)
            one.string(i)
            one.computed_string(i)
            computed_one.string(i)
            computed_one.computed_string(i)
          ].each do |path|
            context "{ #{path}: }" do
              let(:instructions) do
                {
                  path => direction
                }
              end

              it do
                result.each_cons(2) do |left_result, right_result|
                  left_value = value_for(path: path, object: left_result)
                  right_value = value_for(path: path, object: right_result)
                  operator = direction == :asc ? '<=' : '>='

                  expect(left_value).to be.send(operator, right_value)
                end
              end
            end
          end
        end
      end
    end

    context 'with STRING case-insenstive and INTEGER types' do
      paths = %w[
        string(i)
        integer
        computed_string(i)
        computed_integer
        one.string(i)
        one.integer
        one.computed_string(i)
        one.computed_integer
        computed_one.string(i)
        computed_one.integer
        computed_one.computed_string(i)
        computed_one.computed_integer
      ]
      all_possible_instructions = paths
                                  .combination(2)
                                  .flat_map do |path_1, path_2|
        [:asc, 'desc']
          .repeated_permutation(2)
          .map do |pair|
            Hash[[path_1, path_2].zip(pair)]
          end
      end

      all_possible_instructions.each do |instructions|
        context "{ #{instructions} }" do
          let(:instructions) { instructions }

          it do
            result.each_cons(2) do |left_result, right_result|
              (path_1, path_2) = instructions.keys
              (dir_1, dir_2) = instructions.values

              left_value_1 = value_for(path: path_1, object: left_result)
              right_value_1 = value_for(path: path_1, object: right_result)
              operator_1 = dir_1 == :asc ? '<=' : '>='

              expect(left_value_1).to be.send(operator_1, right_value_1)

              next unless left_value_1 == right_value_1

              left_value_2 = value_for(path: path_2, object: left_result)
              right_value_2 = value_for(path: path_2, object: right_result)
              operator_2 = dir_2 == :asc ? '<=' : '>='

              expect(left_value_2).to be.send(operator_2, right_value_2)
            end
          end
        end
      end
    end
  end
end
