# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos with SORTING', type: :request do
  let!(:foo) { FactoryGirl.create(:foo) }
  let!(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:results) { JSON.parse(response.body) }
  let(:results_ids) { results.map { |f| f['id'] } }

  context 'JSON request' do
    before(:each) do
      get foos_path(format: :json), params: params, headers: {}
    end

    context 'db fields' do
      ApplicationRecord::DB_FIELDS.each do |db_field|
        context "with a :#{db_field} attribute type" do
          context 'on the base object' do
            let(:params) do
              { sort: sort_param }
            end

            %w[asc desc].each do |direction|
              context "when direction is #{direction.upcase}" do
                context 'with default case-sensitive sort' do
                  let(:sort_param) { { db_field => direction } }
                  let(:expected_ids) do
                    Foo.order(db_field => direction)
                       .pluck(:id)
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end

                context 'with case-INsensitive sort' do
                  let(:sort_param) { { "#{db_field}(i)": direction } }
                  let(:expected_ids) do
                    Foo.order("LOWER(#{db_field}) #{direction}")
                       .pluck(:id)
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end
              end
            end
          end

          context 'on an associated object' do
            let(:params) do
              { sort: { assoc: sort_param } }
            end

            %w[asc desc].each do |direction|
              context "when direction is #{direction.upcase}" do
                context 'with default case-sensitive sort' do
                  let(:sort_param) { { db_field => direction } }
                  let(:expected_ids) do
                    Foo.joins(:assoc)
                       .merge(Assoc.order(db_field => direction))
                       .pluck(:id)
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end

                context 'with case-INsensitive sort' do
                  let(:sort_param) { { "#{db_field}(i)": direction } }
                  let(:expected_ids) do
                    Foo.joins(:assoc)
                       .merge(Assoc.order("LOWER(#{Assoc.table_name}.#{db_field}) #{direction}"))
                       .pluck(:id)
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end
              end
            end
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
              { sort: sort_param }
            end

            %w[asc desc].each do |direction|
              context "when direction is #{direction.upcase}" do
                context 'with default case-sensitive sort' do
                  let(:sort_param) { { field => direction } }
                  let(:expected_ids) do
                    Foo.all
                       .sort_by { |x| x.send(field).to_s }
                       .map(&:id)
                       .tap { |c| c.reverse! if direction == 'desc' }
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end

                context 'with case-INsensitive sort' do
                  let(:sort_param) { { "#{field}(i)": direction } }
                  let(:expected_ids) do
                    Foo.all
                       .sort_by { |x| x.send(field).to_s.downcase }
                       .map(&:id)
                       .tap { |c| c.reverse! if direction == 'desc' }
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end
              end
            end
          end

          context 'on an associated object' do
            let(:params) do
              { sort: { assoc: sort_param } }
            end

            %w[asc desc].each do |direction|
              context "when direction is #{direction.upcase}" do
                context 'with default case-sensitive sort' do
                  let(:sort_param) { { field => direction } }
                  let(:expected_ids) do
                    Foo.all
                       .sort_by { |x| x.assoc.send(field).to_s }
                       .map(&:id)
                       .tap { |c| c.reverse! if direction == 'desc' }
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end

                context 'with case-INsensitive sort' do
                  let(:sort_param) { { "#{field}(i)": direction } }
                  let(:expected_ids) do
                    Foo.all
                       .sort_by { |x| x.assoc.send(field).to_s.downcase }
                       .map(&:id)
                       .tap { |c| c.reverse! if direction == 'desc' }
                  end

                  it { expect(response).to have_http_status :ok }
                  it { expect(results_ids).to eq expected_ids }
                end
              end
            end
          end
        end
      end
    end
  end
end
