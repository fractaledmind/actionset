# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /things with EXPORTING', type: :request do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_3 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
  end

  context '.csv' do
    let(:result) { response.body }

    before(:each) do
      if Gemika::Env.gem?('rspec', '>= 4')
        get things_path(format: :csv),
            params: { export: instructions },
            as: :json
      else
        get things_path(format: :csv),
            export: instructions,
            as: :json
      end
    end

    context 'with ActiveRecord collection' do
      before(:all) { @active_set = ActiveSet.new(Thing.all) }

      context "{ columns: [{meaningless: 'value'}] }" do
        let(:instructions) do
          {
            columns: [
              {meaningless: 'value'}
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << ['']
            @active_set.each do |_|
              output << %w[—]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ columns: [{key: 'ID'}] }" do
        let(:instructions) do
          {
            columns: [
              { key: 'ID' }
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID]
            @active_set.each do |_|
              output << %w[—]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ columns: [{key: 'ID'}, {key: 'Assoc'}] }" do
        let(:instructions) do
          {
            columns: [
              { key: 'ID' },
              { key: 'Assoc' }
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID Assoc]
            @active_set.each do |_|
              output << %w[— —]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ columns: [{value: 'id'}] }" do
        let(:instructions) do
          {
            columns: [
              { value: 'id' }
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[Id]
            @active_set.each do |item|
              output << [item.id]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ columns: [{value: 'id'}, {value: 'only.string'}] }" do
        let(:instructions) do
          {
            columns: [
              { value: 'id' },
              { value: 'only.string' }
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[Id String]
            @active_set.each do |item|
              output << [item.id, item.only.string]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ columns: [{key: 'ID', value: 'id'}] }" do
        let(:instructions) do
          {
            columns: [
              { key: 'ID',
                value: 'id' }
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID]
            @active_set.each do |item|
              output << [item.id]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ columns: [{key: 'ID', value: 'id'}, {key: 'Assoc', value: 'only.string'}] }" do
        let(:instructions) do
          {
            columns: [
              { key: 'ID',
                value: 'id' },
              { key: 'Assoc',
                value: 'only.string' }
            ]
          }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID Assoc]
            @active_set.each do |item|
              output << [item.id, item.only.string]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context '{  }' do
        let(:instructions) do
          {}
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[hello_world]
            @active_set.each do |item|
              output << [item.integer]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end
    end

    context 'with Enumerable collection' do
    end
  end
end
