# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos with SORTING', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:results) { JSON.parse(response.body) }
  let(:results_ids) { results.map { |f| f['id'] } }

  before(:each) do
    get foos_path, params: params, headers: {}
  end

  context 'with a :calculated_boolean_field attribute' do
    context 'on the base object' do
      let(:params) do
        { sort: sort_param }
      end

      context 'when direction is ASC' do
        let(:direction) { :asc }

        context 'with default case-sensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.calculated_boolean_field.to_s }
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'with case-INsensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field(i)': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.calculated_boolean_field.to_s.downcase }
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end
      end

      context 'when direction is DESC' do
        let(:direction) { :desc }

        context 'with default case-sensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.calculated_boolean_field.to_s }
               .reverse
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'with case-INsensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field(i)': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.calculated_boolean_field.to_s.downcase }
               .reverse
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end
      end
    end

    context 'on an associated object' do
      let(:params) do
        { sort: { assoc: sort_param } }
      end

      context 'when direction is ASC' do
        let(:direction) { :asc }

        context 'with default case-sensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.assoc.calculated_boolean_field.to_s }
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'with case-INsensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field(i)': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.assoc.calculated_boolean_field.to_s.downcase }
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end
      end

      context 'when direction is DESC' do
        let(:direction) { :desc }

        context 'with default case-sensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.assoc.calculated_boolean_field.to_s }
               .reverse
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end

        context 'with case-INsensitive sort' do
          let(:sort_param) { { 'calculated_boolean_field(i)': direction } }
          let(:expected_ids) do
            Foo.all
               .sort_by { |x| x.assoc.calculated_boolean_field.to_s.downcase }
               .reverse
               .map(&:id)
          end

          it { expect(response).to have_http_status :ok }
          it { expect(results_ids).to eq expected_ids }
        end
      end
    end
  end
end
