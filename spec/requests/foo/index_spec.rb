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
      context 'with a :binary attribute type' do
        let(:params) { { filter: { binary: foo.binary } } }
        let(:expected_ids) { Foo.where(binary: foo.binary).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :boolean attribute type' do
        let(:params) { { filter: { boolean: foo.boolean } } }
        let(:expected_ids) { Foo.where(boolean: foo.boolean).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :date attribute type' do
        let(:params) { { filter: { date: foo.date } } }
        let(:expected_ids) { Foo.where(date: foo.date).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :datetime attribute type' do
        let(:params) { { filter: { datetime: foo.datetime } } }
        let(:expected_ids) { Foo.where(datetime: foo.datetime).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :decimal attribute type' do
        let(:params) { { filter: { decimal: foo.decimal } } }
        let(:expected_ids) { Foo.where(decimal: foo.decimal).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :float attribute type' do
        let(:params) { { filter: { float: foo.float } } }
        let(:expected_ids) { Foo.where(float: foo.float).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :integer attribute type' do
        let(:params) { { filter: { integer: foo.integer } } }
        let(:expected_ids) { Foo.where(integer: foo.integer).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :string attribute type' do
        let(:params) { { filter: { string: foo.string } } }
        let(:expected_ids) { Foo.where(string: foo.string).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :text attribute type' do
        let(:params) { { filter: { text: foo.text } } }
        let(:expected_ids) { Foo.where(text: foo.text).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :time attribute type' do
        let(:params) { { filter: { time: foo.assoc.time } } }
        let(:expected_ids) { Foo.where(time: foo.assoc.time).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end
    end

    context 'on an associated object' do
      context 'with a :binary attribute type' do
        let(:params) { { filter: { assoc: { binary: foo.assoc.binary } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { binary: foo.assoc.binary }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :boolean attribute type' do
        let(:params) { { filter: { assoc: { boolean: foo.assoc.boolean } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { boolean: foo.assoc.boolean }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :date attribute type' do
        let(:params) { { filter: { assoc: { date: foo.assoc.date } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { date: foo.assoc.date }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :datetime attribute type' do
        let(:params) { { filter: { assoc: { datetime: foo.assoc.datetime } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { datetime: foo.assoc.datetime }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :decimal attribute type' do
        let(:params) { { filter: { assoc: { decimal: foo.assoc.decimal } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { decimal: foo.assoc.decimal }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :float attribute type' do
        let(:params) { { filter: { assoc: { float: foo.assoc.float } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { float: foo.assoc.float }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :integer attribute type' do
        let(:params) { { filter: { assoc: { integer: foo.assoc.integer } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { integer: foo.assoc.integer }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :string attribute type' do
        let(:params) { { filter: { assoc: { string: foo.assoc.string } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { string: foo.assoc.string }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :text attribute type' do
        let(:params) { { filter: { assoc: { text: foo.assoc.text } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { text: foo.assoc.text }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end

      context 'with a :time attribute type' do
        let(:params) { { filter: { assoc: { time: foo.assoc.time } } } }
        let(:expected_ids) { Foo.joins(:assoc).where(assocs: { time: foo.assoc.time }).pluck(:id) }

        it { expect(response).to have_http_status :ok }
        it { expect(results.map { |f| f['id'] }).to eq expected_ids }
      end
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
