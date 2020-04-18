# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /things?filter', type: :request do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @active_set = ActiveSet.new(Thing.all)
  end

  context '.json' do
    let(:results) { JSON.parse(response.body) }
    let(:result_ids) { results.map { |f| f['id'] } }

    before(:each) do
      if Gemika::Env.gem?('rspec', '>= 4')
        get things_path(format: :json),
            params: { filter: instructions }
      else
        get things_path(format: :json),
            filter: instructions
      end
    end

    # TODO: make request typecasting handle scopes

    # ApplicationRecord::DB_FIELD_TYPES.each do |type|
    #   [1, 2].each do |id|
    #     let(:matching_item) { instance_variable_get("@thing_#{id}") }

    #     all_possible_scope_paths_for(type).each do |path|
    #       context "{ #{path}: }" do
    #         let(:instructions) do
    #           {
    #             path => filter_value_for(object: matching_item, path: path)
    #           }
    #         end

    #         if path.end_with?('_nil_method')
    #           it { expect(result_ids).to eq [] }
    #         else
    #           it { expect(result_ids).to eq [matching_item.id] }
    #         end
    #       end
    #     end
    #   end
    # end
  end
end
