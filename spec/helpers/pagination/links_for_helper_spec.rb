# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pagination::LinksForHelper, type: :helper do
  before(:each) do
    allow(helper).to receive(:params).and_return(params.merge(_recall: { controller: 'things', action: 'index' }))
  end
  let(:params) do
    {}
  end
  let(:set) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }

  describe '.pagination_links_for' do
    subject { helper.pagination_links_for(active_set) }

    context 'total pages is 1' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: set.size) }

      context 'when page number is first/last page' do
        let(:page_number) { 1 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first.disabled',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?1/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end

      context 'when page number is greater than first/last page' do
        let(:page_number) { 10 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?1/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end
    end

    context 'total pages is 2' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 5) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first.disabled',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?2/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is last page' do
        let(:page_number) { 2 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?2/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 10 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?2/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end
    end

    context 'total pages is 3' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 4) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first.disabled',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?3/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is last page' do
        let(:page_number) { 3 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?3/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end

      context 'when page number is middle page' do
        let(:page_number) { 2 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?3/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 10 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?3/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end
    end

    context 'total pages is 5' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 2) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first.disabled',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?5/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is last page' do
        let(:page_number) { 5 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?5/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end

      context 'when page number is middle page' do
        let(:page_number) { 3 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?5/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 10 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?5/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end
    end

    context 'total pages is 10' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 1) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first.disabled',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?10/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is last page' do
        let(:page_number) { 10 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?10/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end

      context 'when page number is middle page' do
        let(:page_number) { 5 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?10/) }
        it {
          should have_selector('.pagination > .page-link.page-next',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last',
                               text: 'Last »')
        }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 20 }

        it { should have_selector('nav.pagination') }
        it {
          should have_selector('.pagination > .page-link.page-first',
                               text: '« First')
        }
        it {
          should have_selector('.pagination > .page-link.page-prev.disabled',
                               text: '‹ Prev')
        }
        it { should have_selector('.pagination > .page-current') }
        it { should match(/Page.*?#{page_number}.*?of.*?10/) }
        it {
          should have_selector('.pagination > .page-link.page-next.disabled',
                               text: 'Next ›')
        }
        it {
          should have_selector('.pagination > .page-link.page-last.disabled',
                               text: 'Last »')
        }
      end
    end
  end
end
