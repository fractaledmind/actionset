# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos with FILTERING', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }

  context 'JSON request' do
    let(:results) { JSON.parse(response.body) }
    let(:results_ids) { results.map { |f| f['id'] } }

    before(:each) do
      get foos_path(format: :json), params: params, headers: {}
    end

    context 'db fields' do
      ApplicationRecord::DB_FIELDS.each do |db_field|
        context "with a :#{db_field} attribute type" do
          context 'on the base object' do
            let(:params) do
              { filter: { db_field => foo.send(db_field) } }
            end
            let(:expected_ids) do
              Foo.where(db_field => foo.send(db_field))
                 .pluck(:id)
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results.size).to be >= 1 }
            it { expect(results_ids).to eq expected_ids }
          end

          context 'on an associated object' do
            let(:params) do
              { filter: { assoc: { db_field => foo.assoc.send(db_field) } } }
            end
            let(:expected_ids) do
              Foo.joins(:assoc)
                 .where(assocs: { db_field => foo.assoc.send(db_field) })
                 .pluck(:id)
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results.size).to be >= 1 }
            it { expect(results_ids).to eq expected_ids }
          end
        end
      end
    end

    context 'computed fields' do
      ApplicationRecord::COMPUTED_FIELDS.each do |computed_field|
        context "with a :#{computed_field} attribute" do
          let(:field) { "computed_#{computed_field}_field" }

          context 'on the base object' do
            let(:params) do
              { filter: { field => foo.send(field) } }
            end
            let(:expected_ids) do
              Foo.all
                 .select { |x| x.send(field) == foo.send(field) }
                 .map(&:id)
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results.size).to be >= 1 }
            it { expect(results_ids).to eq expected_ids }
          end

          context 'on an associated object' do
            let(:params) do
              { filter: { assoc: { field => foo.assoc.send(field) } } }
            end
            let(:expected_ids) do
              Foo.all
                 .select { |x| x.assoc.send(field) == foo.assoc.send(field) }
                 .map(&:id)
            end

            it { expect(response).to have_http_status :ok }
            it { expect(results.size).to be >= 1 }
            it { expect(results_ids).to eq expected_ids }
          end
        end
      end
    end
  end

  context 'HTML request' do
    let(:page) { Capybara.string(response.body) }

    before(:each) do
      get foos_path(format: :html), params: params, headers: {}
    end

    context 'db fields' do
      ApplicationRecord::DB_FIELDS.each do |db_field|
        context "with a :#{db_field} attribute type" do
          context 'on the base object' do
            let(:params) do
              { filter: { db_field => foo.send(db_field) } }
            end
            let(:value_selector) { "#filter_#{db_field}[value=\"#{foo.send(db_field)}\"]" }

            it { expect(response).to have_http_status :ok }
            it { expect(page).to have_css(value_selector) }
          end

          context 'on an associated object' do
            let(:params) do
              { filter: { assoc: { db_field => foo.assoc.send(db_field) } } }
            end
            let(:value_selector) { "#filter_assoc_#{db_field}[value=\"#{foo.assoc.send(db_field)}\"]" }

            it { expect(response).to have_http_status :ok }
            it { expect(page).to have_css(value_selector) }
          end
        end
      end
    end

    context 'computed fields' do
      ApplicationRecord::COMPUTED_FIELDS.each do |computed_field|
        context "with a :#{computed_field} attribute type" do
          let(:field) { "computed_#{computed_field}_field" }

          context 'on the base object' do
            let(:params) do
              { filter: { field => foo.send(field) } }
            end
            let(:value_selector) { "#filter_#{field}[value=\"#{foo.send(field)}\"]" }

            it { expect(response).to have_http_status :ok }
            it { expect(page).to have_css(value_selector) }
          end

          context 'on an associated object' do
            let(:params) do
              { filter: { assoc: { field => foo.assoc.send(field) } } }
            end
            let(:value_selector) { "#filter_assoc_#{field}[value=\"#{foo.assoc.send(field)}\"]" }

            it { expect(response).to have_http_status :ok }
            it { expect(page).to have_css(value_selector) }
          end
        end
      end
    end
  end
end
