# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  before(:all) do
    @thing_1 = FactoryBot.create(:thing)
    @thing_2 = FactoryBot.create(:thing)
    @thing_3 = FactoryBot.create(:thing)
  end

  describe '#paginate' do
    context 'with ActiveRecord collection' do
      before(:all) { @active_set = ActiveSet.new(Thing.all) }
      let(:result) { @active_set.paginate(instructions) }

      context '{ page: 1, size: 1 }' do
        let(:instructions) { { page: 1, size: 1 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id] }
      end

      context '{ page: 2, size: 1 }' do
        let(:instructions) { { page: 2, size: 1 } }

        it { expect(result.map(&:id)).to eq [@thing_2.id] }
      end

      context '{ page: 10, size: 1 }' do
        let(:instructions) { { page: 10, size: 1 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      context '{ page: 1, size: 2 }' do
        let(:instructions) { { page: 1, size: 2 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id, @thing_2.id] }
      end

      context '{ page: 2, size: 2 }' do
        let(:instructions) { { page: 2, size: 2 } }

        it { expect(result.map(&:id)).to eq [@thing_3.id] }
      end

      context '{ page: 10, size: 2 }' do
        let(:instructions) { { page: 10, size: 2 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      context '{ page: 1, size: 3 }' do
        let(:instructions) { { page: 1, size: 3 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 3 }' do
        let(:instructions) { { page: 10, size: 3 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      context '{ page: 1, size: 5 }' do
        let(:instructions) { { page: 1, size: 5 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 5 }' do
        let(:instructions) { { page: 10, size: 5 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      describe "the ActiveRecord_Relation's loaded state" do
        let(:relation) { Thing.all }
        let(:active_set) { ActiveSet.new(relation)}

        before { active_set.paginate(page: 1, size: 1) }

        it { expect(relation.loaded?).to be false }
      end
    end

    context 'with Enumerable collection' do
      before(:all) { @active_set = ActiveSet.new(Thing.all.to_a) }
      let(:result) { @active_set.paginate(instructions) }

      context '{ page: 1, size: 1 }' do
        let(:instructions) { { page: 1, size: 1 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id] }
      end

      context '{ page: 2, size: 1 }' do
        let(:instructions) { { page: 2, size: 1 } }

        it { expect(result.map(&:id)).to eq [@thing_2.id] }
      end

      context '{ page: 10, size: 1 }' do
        let(:instructions) { { page: 10, size: 1 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      context '{ page: 1, size: 2 }' do
        let(:instructions) { { page: 1, size: 2 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id, @thing_2.id] }
      end

      context '{ page: 2, size: 2 }' do
        let(:instructions) { { page: 2, size: 2 } }

        it { expect(result.map(&:id)).to eq [@thing_3.id] }
      end

      context '{ page: 10, size: 2 }' do
        let(:instructions) { { page: 10, size: 2 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      context '{ page: 1, size: 3 }' do
        let(:instructions) { { page: 1, size: 3 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 3 }' do
        let(:instructions) { { page: 10, size: 3 } }

        it { expect(result.map(&:id)).to eq [] }
      end

      context '{ page: 1, size: 5 }' do
        let(:instructions) { { page: 1, size: 5 } }

        it { expect(result.map(&:id)).to eq [@thing_1.id, @thing_2.id, @thing_3.id] }
      end

      context '{ page: 10, size: 5 }' do
        let(:instructions) { { page: 10, size: 5 } }

        it { expect(result.map(&:id)).to eq [] }
      end
    end
  end
end
