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

    context 'on a SCOPE' do
      context 'matching @thing_1' do
        let(:matching_item) { @thing_1 }

        context '{ string_starts_with: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3]
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ string_ends_with: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1]
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_starts_with: } }' do
          let(:instructions) do
            {
              one: {
                'string_starts_with': matching_item.one.string[0..3]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_ends_with: } }' do
          let(:instructions) do
            {
              one: {
                'string_ends_with': matching_item.one.string[-3..-1]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_starts_with: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_starts_with': matching_item.computed_one.string[0..3]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_ends_with: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_ends_with': matching_item.computed_one.string[-3..-1]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end
      end

      context 'matching @thing_2' do
        let(:matching_item) { @thing_2 }

        context '{ string_starts_with: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3]
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ string_ends_with: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1]
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_starts_with: } }' do
          let(:instructions) do
            {
              one: {
                'string_starts_with': matching_item.one.string[0..3]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_ends_with: } }' do
          let(:instructions) do
            {
              one: {
                'string_ends_with': matching_item.one.string[-3..-1]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_starts_with: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_starts_with': matching_item.computed_one.string[0..3]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_ends_with: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_ends_with': matching_item.computed_one.string[-3..-1]
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end
      end
    end

    context 'on a SCOPE and with STRING type' do
      context 'matching @thing_1' do
        let(:matching_item) { @thing_1 }

        context '{ string_starts_with:, string: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3],
              string: matching_item.string
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ string_ends_with:, string: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1],
              string: matching_item.string
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              one: {
                'string_starts_with': matching_item.one.string[0..3],
                string: matching_item.one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              one: {
                'string_ends_with': matching_item.one.string[-3..-1],
                string: matching_item.one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_starts_with': matching_item.computed_one.string[0..3],
                string: matching_item.computed_one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_ends_with': matching_item.computed_one.string[-3..-1],
                string: matching_item.computed_one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end
      end

      context 'matching @thing_2' do
        let(:matching_item) { @thing_2 }

        context '{ string_starts_with:, string: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3],
              string: matching_item.string
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ string_ends_with:, string: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1],
              string: matching_item.string
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              one: {
                'string_starts_with': matching_item.one.string[0..3],
                string: matching_item.one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ one: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              one: {
                'string_ends_with': matching_item.one.string[-3..-1],
                string: matching_item.one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_starts_with': matching_item.computed_one.string[0..3],
                string: matching_item.computed_one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end

        context '{ computed_one: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              computed_one: {
                'string_ends_with': matching_item.computed_one.string[-3..-1],
                string: matching_item.computed_one.string
              }
            }
          end

          it { expect(result.map(&:id)).to eq [matching_item.id] }
        end
      end
    end
  end
end
