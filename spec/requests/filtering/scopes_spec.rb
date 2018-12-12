# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /things?filter', type: :request do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  context '.json' do
    let(:results) { JSON.parse(response.body) }

    before(:each) do
      get things_path(format: :json),
          params: { filter: instructions }
    end

    context 'on a SCOPE' do
      context 'matching @thing_1' do
        let(:matching_item) { @thing_1 }

        context '{ string_starts_with: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3]
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ string_ends_with: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1]
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_starts_with: } }' do
          let(:instructions) do
            {
              only: {
                'string_starts_with': matching_item.only.string[0..3]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_ends_with: } }' do
          let(:instructions) do
            {
              only: {
                'string_ends_with': matching_item.only.string[-3..-1]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_starts_with: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_starts_with': matching_item.computed_only.string[0..3]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_ends_with: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_ends_with': matching_item.computed_only.string[-3..-1]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
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

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ string_ends_with: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1]
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_starts_with: } }' do
          let(:instructions) do
            {
              only: {
                'string_starts_with': matching_item.only.string[0..3]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_ends_with: } }' do
          let(:instructions) do
            {
              only: {
                'string_ends_with': matching_item.only.string[-3..-1]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_starts_with: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_starts_with': matching_item.computed_only.string[0..3]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_ends_with: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_ends_with': matching_item.computed_only.string[-3..-1]
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
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

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ string_ends_with:, string: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1],
              string: matching_item.string
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              only: {
                'string_starts_with': matching_item.only.string[0..3],
                string: matching_item.only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              only: {
                'string_ends_with': matching_item.only.string[-3..-1],
                string: matching_item.only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_starts_with': matching_item.computed_only.string[0..3],
                string: matching_item.computed_only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_ends_with': matching_item.computed_only.string[-3..-1],
                string: matching_item.computed_only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
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

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ string_ends_with:, string: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1],
              string: matching_item.string
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              only: {
                'string_starts_with': matching_item.only.string[0..3],
                string: matching_item.only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ only: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              only: {
                'string_ends_with': matching_item.only.string[-3..-1],
                string: matching_item.only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_starts_with': matching_item.computed_only.string[0..3],
                string: matching_item.computed_only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end

        context '{ computed_only: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              computed_only: {
                'string_ends_with': matching_item.computed_only.string[-3..-1],
                string: matching_item.computed_only.string
              }
            }
          end

          it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
        end
      end
    end
  end
end
