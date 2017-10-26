# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos with PAGINATING', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:set) { Foo.all }
  let(:results) { JSON.parse(response.body) }
  let(:results_ids) { results.map { |f| f['id'] } }

  context 'JSON request' do
    before(:each) do
      get foos_path(format: :json), params: params, headers: {}
    end

    let(:params) do
      {
        paginate: {
          page: page,
          size: size
        }
      }
    end

    context 'when page size is smaller than set size' do
      context 'when set is divisible by page size' do
        let(:size) { 1 }

        context 'when on first page' do
          let(:page) { 1 }
          let(:expected_ids) do
            Foo.where(id: 1)
               .pluck(:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'when on last page' do
          let(:page) { 3 }
          let(:expected_ids) do
            Foo.where(id: 3)
               .pluck(:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'when on irrational page' do
          let(:page) { 10 }
          let(:expected_ids) do
            Foo.none
               .pluck(:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end
      end

      context 'when set is not divisible by page size' do
        let(:size) { 2 }

        context 'when on first page' do
          let(:page) { 1 }
          let(:expected_ids) do
            Foo.where(id: [1, 2])
               .pluck(:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'when on last page' do
          let(:page) { 2 }
          let(:expected_ids) do
            Foo.where(id: 3)
               .pluck(:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'when on irrational page' do
          let(:page) { 10 }
          let(:expected_ids) do
            Foo.none
               .pluck(:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end
      end
    end

    context 'when page size is equal to set size' do
      let(:size) { set.count }

      context 'when on only page' do
        let(:page) { 1 }
        let(:expected_ids) do
          Foo.all
             .pluck(:id)
        end

        it { expect(response).to have_http_status :ok }
        it { expect(results_ids).to eq expected_ids }
      end

      context 'when on irrational page' do
        let(:paginate_structure) { { page: 10, size: size } }
        let(:page) { 10 }
        let(:expected_ids) do
          Foo.none
             .pluck(:id)
        end

        it { expect(response).to have_http_status :ok }
        it { expect(results_ids).to eq expected_ids }
      end
    end

    context 'when page size is greater than set size' do
      let(:size) { set.count + 1 }

      context 'when on only page' do
        let(:page) { 1 }
        let(:expected_ids) do
          Foo.all
             .pluck(:id)
        end

        it { expect(response).to have_http_status :ok }
        it { expect(results_ids).to eq expected_ids }
      end

      context 'when on irrational page' do
        let(:page) { 10 }
        let(:expected_ids) do
          Foo.none
             .pluck(:id)
        end

        it { expect(response).to have_http_status :ok }
        it { expect(results_ids).to eq expected_ids }
      end
    end
  end
end
