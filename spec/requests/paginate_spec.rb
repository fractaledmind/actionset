# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /things?paginate', type: :request do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_2 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
    @thing_3 = FactoryBot.create(:thing, only: FactoryBot.create(:only))
  end
  after(:all) { Thing.delete_all; Only.delete_all }

  context '.json' do
    let(:results) { JSON.parse(response.body) }
    let(:result_ids) { results.map { |f| f['id'] } }

    before(:each) do
      get things_path(format: :json),
          params: { paginate: instructions }
    end

    context 'with ActiveRecord collection' do
      before(:all) { @active_set = ActiveSet.new(Thing.all) }

      context '{ page: 1, size: 1 }' do
        let(:instructions) { { page: 1, size: 1 } }

        it { expect(result_ids).to eq [@thing_1.id] }
      end

      context '{ page: 2, size: 1 }' do
        let(:instructions) { { page: 2, size: 1 } }

        it { expect(result_ids).to eq [@thing_2.id] }
      end

      context '{ page: 10, size: 1 }' do
        let(:instructions) { { page: 10, size: 1 } }

        it { expect(result_ids).to eq [] }
      end

      context '{ page: 1, size: 2 }' do
        let(:instructions) { { page: 1, size: 2 } }

        it { expect(result_ids).to eq [@thing_1.id, @thing_2.id] }
      end

      context '{ page: 2, size: 2 }' do
        let(:instructions) { { page: 2, size: 2 } }

        it { expect(result_ids).to eq [@thing_3.id] }
      end

      context '{ page: 10, size: 2 }' do
        let(:instructions) { { page: 10, size: 2 } }

        it { expect(result_ids).to eq [] }
      end

      context '{ page: 1, size: 3 }' do
        let(:instructions) { { page: 1, size: 3 } }

        it { expect(result_ids).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 3 }' do
        let(:instructions) { { page: 10, size: 3 } }

        it { expect(result_ids).to eq [] }
      end

      context '{ page: 1, size: 5 }' do
        let(:instructions) { { page: 1, size: 5 } }

        it { expect(result_ids).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 5 }' do
        let(:instructions) { { page: 10, size: 5 } }

        it { expect(result_ids).to eq [] }
      end
    end

    context 'with Enumerable collection' do
      before(:all) { @active_set = ActiveSet.new(Thing.all.to_a) }

      context '{ page: 1, size: 1 }' do
        let(:instructions) { { page: 1, size: 1 } }

        it { expect(result_ids).to eq [@thing_1.id] }
      end

      context '{ page: 2, size: 1 }' do
        let(:instructions) { { page: 2, size: 1 } }

        it { expect(result_ids).to eq [@thing_2.id] }
      end

      context '{ page: 10, size: 1 }' do
        let(:instructions) { { page: 10, size: 1 } }

        it { expect(result_ids).to eq [] }
      end

      context '{ page: 1, size: 2 }' do
        let(:instructions) { { page: 1, size: 2 } }

        it { expect(result_ids).to eq [@thing_1.id, @thing_2.id] }
      end

      context '{ page: 2, size: 2 }' do
        let(:instructions) { { page: 2, size: 2 } }

        it { expect(result_ids).to eq [@thing_3.id] }
      end

      context '{ page: 10, size: 2 }' do
        let(:instructions) { { page: 10, size: 2 } }

        it { expect(result_ids).to eq [] }
      end

      context '{ page: 1, size: 3 }' do
        let(:instructions) { { page: 1, size: 3 } }

        it { expect(result_ids).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 3 }' do
        let(:instructions) { { page: 10, size: 3 } }

        it { expect(result_ids).to eq [] }
      end

      context '{ page: 1, size: 5 }' do
        let(:instructions) { { page: 1, size: 5 } }

        it { expect(result_ids).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 5 }' do
        let(:instructions) { { page: 10, size: 5 } }

        it { expect(result_ids).to eq [] }
      end
    end
  end
end
