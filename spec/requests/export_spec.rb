# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos with EXPORTING', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:set) { Foo.all }
  let(:results) { CSV.parse(response.body) }
  let(:results_ids) { results.map { |f| f['id'] } }

  context 'CSV request' do
    before(:each) do
      get foos_path(format: :csv), params: params, headers: {}
    end

    let(:params) do
      {
        transform: {
          columns: columns
        }
      }
    end

    context 'when columns passed as params' do
      context 'when value is nil' do
        context 'when key present' do
          context 'when one column' do
            let(:columns) do
              [
                { key: 'Name' }
              ]
            end

            let(:expected_csv) do
              [['Name'], ['—'], ['—'], ['—']]
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end

          context 'when multiple columns' do
            let(:columns) do
              [
                { key: 'Name' },
                { key: 'Assoc' }
              ]
            end

            let(:expected_csv) do
              [['Name', 'Assoc'], ['—', '—'], ['—', '—'], ['—', '—']]
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end
        end

        context 'when key is not present' do
          context 'when one column' do
            let(:columns) do
              [
                {}
              ]
            end

            let(:expected_csv) do
              [[''], ['—'], ['—'], ['—']]
            end

            it { expect(response).to have_http_status :ok }
            # it { expect(results).to eq expected_csv }
          end

          context 'when multiple columns' do
            let(:columns) do
              [
                {},
                {}
              ]
            end

            let(:expected_csv) do
              [['', ''], ['—', '—'], ['—', '—'], ['—', '—']]
            end

            it { expect(response).to have_http_status :ok }
            # it { expect(results).to eq expected_csv }
          end
        end
      end

      context 'when value is keypath' do
        context 'when key present' do
          context 'when one column' do
            let(:columns) do
              [
                { key: 'Attribute',
                  value: 'string' }
              ]
            end

            let(:expected_csv) do
              [].tap do |a|
                a << ['Attribute']
                set.each { |f| a << [f.string] }
              end
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end

          context 'when multiple columns' do
            let(:columns) do
              [
                { key: 'Attribute',
                  value: 'string' },
                { key: 'Association',
                  value: 'assoc.integer' }
              ]
            end

            let(:expected_csv) do
              [].tap do |a|
                a << ['Attribute', 'Association']
                set.each { |f| a << [f.string, f.assoc.integer.to_s] }
              end
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end
        end

        context 'when key is not present' do
          context 'when one column' do
            let(:columns) do
              [
                { value: 'boolean' }
              ]
            end

            let(:expected_csv) do
              [].tap do |a|
                a << ['Boolean']
                set.each { |f| a << [f.boolean.to_s] }
              end
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end

          context 'when multiple columns' do
            let(:columns) do
              [
                { value: 'boolean' },
                { value: 'assoc.float' }
              ]
            end

            let(:expected_csv) do
              [].tap do |a|
                a << ['Boolean', 'Float']
                set.each { |f| a << [f.boolean.to_s, f.assoc.float.to_s] }
              end
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end
        end
      end

      context 'when value is method' do
        context 'when key present' do
          context 'when one column' do
            let(:columns) do
              [
                { key: 'Attribute',
                  'value*': 'proc_item_string' }
              ]
            end

            let(:expected_csv) do
              [].tap do |a|
                a << ['Attribute']
                set.each { |f| a << [f.string] }
              end
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end

          context 'when multiple columns' do
            let(:columns) do
              [
                { key: 'Attribute',
                  'value*': 'proc_item_string' },
                { key: 'Association',
                  'value*': 'proc_item_assoc_integer' }
              ]
            end

            let(:expected_csv) do
              [].tap do |a|
                a << ['Attribute', 'Association']
                set.each { |f| a << [f.string, f.assoc.integer.to_s] }
              end
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results).to eq expected_csv }
          end
        end

        # DON'T DO THIS.
        # THIS WILL BLOW THINGS UP.
        # IF VALUE IF PROC, SUPPLY THE KEY
        # context 'when key is not present' do
        # end
      end
    end

    context 'when columns defined in controller' do
    end

    context 'when no columns' do
    end
  end
end
