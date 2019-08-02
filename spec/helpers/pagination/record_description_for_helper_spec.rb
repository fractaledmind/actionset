# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pagination::RecordDescriptionForHelper, type: :helper do
  before(:each) do
    allow(helper).to receive(:params).and_return(params.merge(_recall: { controller: 'things', action: 'index' }))
  end
  let(:params) do
    {}
  end
  let(:set) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }

  describe '.pagination_record_description_for' do
    subject { helper.pagination_record_description_for(active_set) }

    context 'size: 10' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: set.size) }

      context 'page_number: 1' do
        let(:page_number) { 1 }

        it { should eql('1&nbsp;&ndash;&nbsp;10&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 10' do
        let(:page_number) { 10 }

        it { should eql('None&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end
    end

    context 'size: 5' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 5) }

      context 'page_number: 1' do
        let(:page_number) { 1 }

        it { should eql('1&nbsp;&ndash;&nbsp;5&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 2' do
        let(:page_number) { 2 }

        it { should eql('6&nbsp;&ndash;&nbsp;10&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 10' do
        let(:page_number) { 10 }

        it { should eql('None&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end
    end

    context 'size: 4' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 4) }

      context 'page_number: 1' do
        let(:page_number) { 1 }

        it { should eql('1&nbsp;&ndash;&nbsp;4&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 2' do
        let(:page_number) { 2 }

        it { should eql('5&nbsp;&ndash;&nbsp;8&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 3' do
        let(:page_number) { 3 }

        it { should eql('9&nbsp;&ndash;&nbsp;10&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 10' do
        let(:page_number) { 10 }

        it { should eql('None&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end
    end

    context 'size: 2' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 2) }

      context 'page_number: 1' do
        let(:page_number) { 1 }

        it { should eql('1&nbsp;&ndash;&nbsp;2&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 3' do
        let(:page_number) { 3 }

        it { should eql('5&nbsp;&ndash;&nbsp;6&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 5' do
        let(:page_number) { 5 }

        it { should eql('9&nbsp;&ndash;&nbsp;10&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 10' do
        let(:page_number) { 10 }

        it { should eql('None&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end
    end

    context 'size: 1' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 1) }

      context 'page_number: 1' do
        let(:page_number) { 1 }

        it { should eql('1&nbsp;&ndash;&nbsp;1&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 5' do
        let(:page_number) { 5 }

        it { should eql('5&nbsp;&ndash;&nbsp;5&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 10' do
        let(:page_number) { 10 }

        it { should eql('10&nbsp;&ndash;&nbsp;10&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end

      context 'page_number: 20' do
        let(:page_number) { 20 }

        it { should eql('None&nbsp;of&nbsp;<strong>10</strong>&nbsp;records') }
      end
    end
  end
end
