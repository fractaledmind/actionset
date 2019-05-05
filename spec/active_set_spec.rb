# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveSet do
  context 'as a Decorator of the set it is initialized with' do
    describe 'a Set' do
      it { expect(ActiveSet.new(Set.new)).to respond_to :superset? }
    end

    describe 'an Array' do
      it { expect(ActiveSet.new([])).to respond_to :index }
    end

    it 'extends Enumberable' do
      expect(ActiveSet.new([])).to respond_to :each
    end
  end

  context '#filter' do
    let(:set) { [1, 2, 3] }
    let(:active_set) { ActiveSet.new(set) }
    let(:filtered_set) { active_set.filter(filter_instructions) }
    let(:filter_instructions) { { itself: 1 } }

    it 'returns the filtered set' do
      expect(filtered_set).to eq [1]
    end

    it 'presents the filtered set as the `view`' do
      expect(filtered_set.view).to eq [1]
    end

    it 'keeps the original set as the `set`' do
      expect(filtered_set.set).to eq set
    end
  end

  context '#sort' do
    let(:set) { [1, 2, 3] }
    let(:active_set) { ActiveSet.new(set) }
    let(:sorted_set) { active_set.sort(sort_instructions) }
    let(:sort_instructions) { { itself: :desc } }

    it 'returns the sorted set' do
      expect(sorted_set).to eq [3, 2, 1]
    end

    it 'presents the sorted set as the `view`' do
      expect(sorted_set.view).to eq [3, 2, 1]
    end

    it 'keeps the original set as the `set`' do
      expect(sorted_set.set).to eq set
    end
  end

  context '#paginate' do
    let(:set) { [1, 2, 3] }
    let(:active_set) { ActiveSet.new(set) }
    let(:paginated_set) { active_set.paginate(paginate_instructions) }
    let(:paginate_instructions) { { page: 1, size: 1, count: 3 } }

    it 'returns the paginated set' do
      expect(paginated_set).to eq [1]
    end

    it 'presents the paginated set as the `view`' do
      expect(paginated_set.view).to eq [1]
    end

    it 'keeps the original set as the `set`' do
      expect(paginated_set.set).to eq set
    end

    it 'saves the passed instructions' do
      expect(paginated_set.instructions).to eq(paginate: paginate_instructions)
    end

    context 'with no instructions' do
      let(:paginate_instructions) { {} }

      it 'returns the paginated set' do
        expect(paginated_set).to eq [1, 2, 3]
      end

      it 'presents the paginated set as the `view`' do
        expect(paginated_set.view).to eq [1, 2, 3]
      end

      it 'saves the default instructions' do
        expect(paginated_set.instructions).to eq(paginate: { page: 1, size: 25, count: 3 })
      end
    end
  end
end
