# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos with FILTERING', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:results) { JSON.parse(response.body) }
  let(:results_ids) { results.map { |f| f['id'] } }

  before(:each) do
    get foos_path(format: :json), params: params, headers: {}
  end

  context 'with a :date attribute type' do
    context 'on the base object' do
      let(:params) do
        { filter: { date: foo.date } }
      end
      let(:expected_ids) do
        Foo.where(date: foo.date)
           .pluck(:id)
      end

      it { expect(response).to have_http_status :ok }
      it { expect(results.size).to be >= 1 }
      it { expect(results_ids).to eq expected_ids }
    end

    context 'on an associated object' do
      let(:params) do
        { filter: { assoc: { date: foo.assoc.date } } }
      end
      let(:expected_ids) do
        Foo.joins(:assoc)
           .where(assocs: { date: foo.assoc.date })
           .pluck(:id)
      end

      it { expect(response).to have_http_status :ok }
      it { expect(results.size).to be >= 1 }
      it { expect(results_ids).to eq expected_ids }
    end
  end
end
