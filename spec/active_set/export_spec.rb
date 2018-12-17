# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, one: FactoryBot.create(:one))
    @thing_2 = FactoryBot.create(:thing, one: FactoryBot.create(:one))
    @thing_3 = FactoryBot.create(:thing, one: FactoryBot.create(:one))
  end
  after(:all) { Thing.delete_all }

  describe '#export' do
    context 'with ActiveRecord collection' do
      before(:all) { @active_set = ActiveSet.new(Thing.all) }
      let(:result) { @active_set.export(instructions) }

      context '{ format: :csv, columns: [{}] }' do
        let(:instructions) do
          { format: :csv,
            columns: [
              {}
            ] }
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

      context '{ format: :csv, columns: [{}, {}] }' do
        let(:instructions) do
          { format: :csv,
            columns: [
              {},
              {}
            ] }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << ['', '']
            @active_set.each do |_|
              output << %w[— —]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ format: :csv, columns: [{key: 'ID'}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { key: 'ID' }
            ] }
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

      context "{ format: :csv, columns: [{key: 'ID'}, {key: 'Assoc'}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { key: 'ID' },
              { key: 'Assoc' }
            ] }
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

      context "{ format: :csv, columns: [{value: 'id'}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { value: 'id' }
            ] }
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

      context "{ format: :csv, columns: [{value: 'id'}, {value: 'one.string'}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { value: 'id' },
              { value: 'one.string' }
            ] }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[Id String]
            @active_set.each do |item|
              output << [item.id, item.one.string]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ format: :csv, columns: [{key: 'ID', value: 'id'}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { key: 'ID',
                value: 'id' }
            ] }
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

      context "{ format: :csv, columns: [{key: 'ID', value: 'id'}, {key: 'Assoc', value: 'one.string'}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { key: 'ID',
                value: 'id' },
              { key: 'Assoc',
                value: 'one.string' }
            ] }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID Assoc]
            @active_set.each do |item|
              output << [item.id, item.one.string]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{ format: :csv, columns: [{key: 'ID', value: ->(item) { item.id * 2 }}] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { key: 'ID',
                value: ->(item) { item.id * 2 } }
            ] }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID]
            @active_set.each do |item|
              output << [(item.id * 2)]
            end
          end
        end

        it { expect(result).to eq expected_csv }
      end

      context "{
        format: :csv,
        columns: [
          { key: 'ID',
            value: ->(item) { item.id * 2 } },
          { key: 'Assoc',
            value: ->(item) { item.one.string.upcase } }
        ] }" do
        let(:instructions) do
          { format: :csv,
            columns: [
              { key: 'ID',
                value: ->(item) { item.id * 2 } },
              { key: 'Assoc',
                value: ->(item) { item.one.string.upcase } }
            ] }
        end
        let(:expected_csv) do
          ::CSV.generate do |output|
            output << %w[ID Assoc]
            @active_set.each do |item|
              output << [(item.id * 2), item.one.string.upcase]
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
