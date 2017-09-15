# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:results) { JSON.parse(response.body) }

  before(:each) do
    get foos_path, params: params, headers: {}
  end

  context 'with no params' do
    let(:params) { {} }

    it { expect(response).to have_http_status :ok }
    it { expect(results.map { |f| f['id'] }).to eq [1, 2, 3] }
  end

  context 'with filter params' do
    context 'on the base object' do
      let(:params) { { filter: { string: foo.string } } }
      let(:expected_ids) { Foo.where(string: foo.string).pluck(:id) }

      it { expect(response).to have_http_status :ok }
      it { expect(results.map { |f| f['id'] }).to eq expected_ids }
    end

    context 'on an associated object' do
      let(:params) { { filter: { assoc: { string: foo.assoc.string } } } }
      let(:expected_ids) { Foo.joins(:assoc).where(assocs: { string: foo.assoc.string }).pluck(:id) }

      it { expect(response).to have_http_status :ok }
      it { expect(results.map { |f| f['id'] }).to eq expected_ids }
    end
  end

  context 'with sort params' do
    context 'on the base object' do
      let(:params) { { sort: { string: :asc } } }
      let(:expected_ids) { Foo.order(string: :asc).pluck(:id) }

      it { expect(response).to have_http_status :ok }
      it { expect(results.map { |f| f['id'] }).to eq expected_ids }
    end

    context 'on an associated object' do
      let(:params) { { sort: { assoc: { string: :asc } } } }
      let(:expected_ids) { Foo.joins(:assoc).merge(Assoc.order(string: :asc)).pluck(:id) }

      it { expect(response).to have_http_status :ok }
      it { expect(results.map { |f| f['id'] }).to eq expected_ids }
    end
  end
end
