# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActionSet::Helpers::HelperMethods, type: :helper do
  before(:each) do
    allow(controller).to receive(:controller_path).and_return('foos')
    allow(controller).to receive(:params).and_return(ActionController::Parameters.new(params))
  end

  describe '.sort_link_for' do
    subject { helper.sort_link_for(column, title) }
    let(:column) { 'string' }
    let(:params) do
      {
        sort: {
          column => direction
        }
      }
    end

    context 'when title is not passed in' do
      let(:title) { nil }

      context 'and direction is nil' do
        let(:direction) { nil }

        it { should match '<a href.*?</a>' }
        it { should match "sort%5B#{column}%5D=asc" }
        it { should match column.titleize }
      end

      context 'and direction is ASC' do
        let(:direction) { 'asc' }

        it { should match '<a href.*?</a>' }
        it { should match "sort%5B#{column}%5D=desc" }
        it { should match column.titleize }
      end

      context 'and direction is DESC' do
        let(:direction) { :desc }

        it { should match '<a href.*?</a>' }
        it { should match "sort%5B#{column}%5D=asc" }
        it { should match column.titleize }
      end
    end

    context 'when title is passed in' do
      let(:title) { 'Foo' }

      context 'and direction is nil' do
        let(:direction) { nil }

        it { should match '<a href.*?</a>' }
        it { should match "sort%5B#{column}%5D=asc" }
        it { should match title }
      end

      context 'and direction is ASC' do
        let(:direction) { 'asc' }

        it { should match '<a href.*?</a>' }
        it { should match "sort%5B#{column}%5D=desc" }
        it { should match title }
      end

      context 'and direction is DESC' do
        let(:direction) { :desc }

        it { should match '<a href.*?</a>' }
        it { should match "sort%5B#{column}%5D=asc" }
        it { should match title }
      end
    end
  end

  describe '.pagination_links_for' do
    subject { helper.pagination_links_for(active_set) }
    let(:params) { {} }
    let(:set) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] }

    context 'total pages is 1' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: set.size) }

      context 'when page number is first/last page' do
        let(:page_number) { 1 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should_not have_selector('.pagination > li.page.first') }
        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end

      context 'when page number is greater than first/last page' do
        let(:page_number) { 10 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end
    end

    context 'total pages is 2' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 5) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 2 })) }

        it { should_not have_selector('.pagination > li.page.first') }
        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
      end

      context 'when page number is last page' do
        let(:page_number) { 2 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 10 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end
    end

    context 'total pages is 3' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 4) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 3 })) }

        it { should_not have_selector('.pagination > li.page.first') }
        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
      end

      context 'when page number is last page' do
        let(:page_number) { 3 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end

      context 'when page number is middle page' do
        let(:page_number) { 2 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 3 })) }

        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 10 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end
    end

    context 'total pages is 5' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 2) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page.next_gap.disabled') }
        it { should have_link('…', href: '#') }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 5 })) }

        it { should_not have_selector('.pagination > li.page.first') }
        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
      end

      context 'when page number is last page' do
        let(:page_number) { 5 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 4 })) }

        it { should have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should have_link('…', href: '#') }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('4', href: foos_path(paginate: { page: 4 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('5', href: foos_path(paginate: { page: 5 })) }

        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end

      context 'when page number is middle page' do
        let(:page_number) { 3 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('4', href: foos_path(paginate: { page: 4 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('5', href: foos_path(paginate: { page: 5 })) }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 4 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 5 })) }

        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 10 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end
    end

    context 'total pages is 10' do
      let(:active_set) { ActiveSet.new(set).paginate(page: page_number, size: 1) }

      context 'when page number is first page' do
        let(:page_number) { 1 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('1', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('2', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page.next_gap.disabled') }
        it { should have_link('…', href: '#') }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 2 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 10 })) }

        it { should_not have_selector('.pagination > li.page.first') }
        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
      end

      context 'when page number is last page' do
        let(:page_number) { 10 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 9 })) }

        it { should have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should have_link('…', href: '#') }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('8', href: foos_path(paginate: { page: 8 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('9', href: foos_path(paginate: { page: 9 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('10', href: foos_path(paginate: { page: 10 })) }

        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end

      context 'when page number is middle page' do
        let(:page_number) { 5 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should have_selector('.pagination > li.page.prev') }
        it { should have_link('‹ Prev', href: foos_path(paginate: { page: 4 })) }

        it { should have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should have_link('…', href: '#') }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('3', href: foos_path(paginate: { page: 3 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('4', href: foos_path(paginate: { page: 4 })) }

        it { should have_selector('.pagination > li.page.active') }
        it { should have_link('5', href: foos_path(paginate: { page: 5 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('6', href: foos_path(paginate: { page: 6 })) }

        it { should have_selector('.pagination > li.page') }
        it { should have_link('7', href: foos_path(paginate: { page: 7 })) }

        it { should have_selector('.pagination > li.page.next_gap.disabled') }
        it { should have_link('…', href: '#') }

        it { should have_selector('.pagination > li.page.next') }
        it { should have_link('Next ›', href: foos_path(paginate: { page: 6 })) }

        it { should have_selector('.pagination > li.page.last') }
        it { should have_link('Last »', href: foos_path(paginate: { page: 10 })) }
      end

      context 'when page number is greater than last page' do
        let(:page_number) { 20 }

        it { should have_selector('ul.pagination') }

        it { should have_selector('.pagination > li.page.first') }
        it { should have_link('« First', href: foos_path(paginate: { page: 1 })) }

        it { should_not have_selector('.pagination > li.page.prev') }
        it { should_not have_selector('.pagination > li.page.prev_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next_gap.disabled') }
        it { should_not have_selector('.pagination > li.page.next') }
        it { should_not have_selector('.pagination > li.page.last') }
      end
    end
  end
end
