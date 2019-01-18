# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end
  after(:all) { Thing.delete_all }

  describe '#filter' do
    let(:results) { @active_set.filter(instructions) }
    let(:result_ids) { results.map(&:id) }

    (ApplicationRecord::DB_FIELD_TYPES - %w[date float integer]).each do |type|
      [1, 2].each do |id|
        # inclusive predicators
        %i[
          is_present
          not_blank
          not_null
        ].each do |operator|
          %W[
            #{type}/p/
            only.#{type}/p/
          ].each do |path|
            context "{ #{path}: #{operator} }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instructions) do
                {
                  path => operator
                }
              end

              it { expect(result_ids).to include matching_item.id }
            end
          end
        end

        # exclusive predicators
        %i[
          not_present
          is_blank
          is_null
        ].each do |operator|
          %W[
            #{type}/p/
            only.#{type}/p/
          ].each do |path|
            context "{ #{path}: #{operator} }" do
              let(:matching_item) { instance_variable_get("@thing_#{id}") }
              let(:instructions) do
                {
                  path => operator
                }
              end

              it { expect(result_ids).not_to include matching_item.id }
            end
          end
        end
      end
    end

    # boolean operators
    %W[
      boolean/p/
    ].each do |path|
      context "{ #{path}: is_true }" do
        let(:instructions) do
          {
            path => :is_true
          }
        end

        it { expect(result_ids).to match Thing.where(boolean: true).pluck(:id) }
      end

      context "{ #{path}: is_false }" do
        let(:instructions) do
          {
            path => :is_false
          }
        end

        it { expect(result_ids).to match Thing.where(boolean: false).pluck(:id) }
      end

      context "{ #{path}: not_true }" do
        let(:instructions) do
          {
            path => :not_true
          }
        end

        it { expect(result_ids).to match Thing.where.not(boolean: true).pluck(:id) }
      end

      context "{ #{path}: not_false }" do
        let(:instructions) do
          {
            path => :not_false
          }
        end

        it { expect(result_ids).to match Thing.where.not(boolean: false).pluck(:id) }
      end
    end
  end
end
