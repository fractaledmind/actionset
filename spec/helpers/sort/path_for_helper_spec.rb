# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sort::PathForHelper, type: :helper do
  before(:each) do
    allow(helper).to receive(:params).and_return(params.merge(_recall: { controller: 'things', action: 'index' }))
  end
  let(:params) do
    {
      sort: {
        attribute => direction
      }
    }
  end

  describe '.sort_path_for' do
    subject { helper.sort_path_for(attribute) }
    let(:attribute) { 'attribute' }

    context 'and direction is nil' do
      let(:direction) { nil }

      it { should eq '/things?sort%5Battribute%5D=asc' }
    end

    context 'and direction is ASC' do
      let(:direction) { 'ASC' }

      it { should eq '/things?sort%5Battribute%5D=desc' }
    end

    context 'and direction is ASCENDING' do
      let(:direction) { 'ASCENDING' }

      it { should eq '/things?sort%5Battribute%5D=desc' }
    end

    context 'and direction is asc' do
      let(:direction) { 'asc' }

      it { should eq '/things?sort%5Battribute%5D=desc' }
    end

    context 'and direction is ascending' do
      let(:direction) { 'ascending' }

      it { should eq '/things?sort%5Battribute%5D=desc' }
    end

    context 'and direction is DESC' do
      let(:direction) { :DESC }

      it { should eq '/things?sort%5Battribute%5D=asc' }
    end

    context 'and direction is DESCENDING' do
      let(:direction) { :DESCENDING }

      it { should eq '/things?sort%5Battribute%5D=asc' }
    end

    context 'and direction is desc' do
      let(:direction) { :desc }

      it { should eq '/things?sort%5Battribute%5D=asc' }
    end

    context 'and direction is descending' do
      let(:direction) { :descending }

      it { should eq '/things?sort%5Battribute%5D=asc' }
    end

    context 'and direction is a non-valid direction' do
      let(:direction) { 'non-valid' }

      it { should eq '/things?sort%5Battribute%5D=asc' }
    end
  end
end
