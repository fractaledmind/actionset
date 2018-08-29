# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sort::LinkForHelper, type: :helper do
  before(:each) do
    allow(helper).to receive(:params).and_return(params.merge(_recall: { controller: 'foos', action: 'index' }))
  end
  let(:params) do
    {
      sort: {
        attribute => direction
      }
    }
  end

  describe '.sort_link_for' do
    subject { helper.sort_link_for(attribute, name) }
    let(:attribute) { 'attribute' }

    context 'when name is not passed in' do
      let(:name) { nil }

      context 'and direction is nil' do
        let(:direction) { nil }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is ASC' do
        let(:direction) { 'ASC' }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is ASCENDING' do
        let(:direction) { 'ASCENDING' }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is asc' do
        let(:direction) { 'asc' }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is ascending' do
        let(:direction) { 'ascending' }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is DESC' do
        let(:direction) { :DESC }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is DESCENDING' do
        let(:direction) { :DESCENDING }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is desc' do
        let(:direction) { :desc }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is descending' do
        let(:direction) { :descending }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is a non-valid direction' do
        let(:direction) { 'non-valid' }

        it { should have_selector('a', text: attribute.titleize) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end
    end

    context 'when name is passed in' do
      let(:name) { 'Name' }

      context 'and direction is nil' do
        let(:direction) { nil }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is ASC' do
        let(:direction) { 'ASC' }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is ASCENDING' do
        let(:direction) { 'ASCENDING' }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is asc' do
        let(:direction) { 'asc' }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is ascending' do
        let(:direction) { 'ascending' }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=desc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in descending order"]]) }
      end

      context 'and direction is DESC' do
        let(:direction) { :DESC }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is DESCENDING' do
        let(:direction) { :DESCENDING }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is desc' do
        let(:direction) { :desc }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is descending' do
        let(:direction) { :descending }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end

      context 'and direction is a non-valid direction' do
        let(:direction) { 'non-valid' }

        it { should have_selector('a', text: name) }
        it { should have_selector('[href="/foos?sort%5Battribute%5D=asc"]') }
        it { should have_selector(%q[[aria-label="sort by 'attribute' in ascending order"]]) }
      end
    end
  end
end
