# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sort::CurrentDirectionForHelper, type: :helper do
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

  describe '.current_sort_direction_for' do
    subject { helper.current_sort_direction_for(attribute, format: format) }
    let(:attribute) { 'attribute' }

    context 'when format is short' do
      let(:format) { :short }

      context 'and direction is nil' do
        let(:direction) { nil }

        it { should eq '' }
      end

      context 'and direction is ASC' do
        let(:direction) { 'ASC' }

        it { should eq 'asc' }
      end

      context 'and direction is ASCENDING' do
        let(:direction) { 'ASCENDING' }

        it { should eq 'asc' }
      end

      context 'and direction is asc' do
        let(:direction) { 'asc' }

        it { should eq 'asc' }
      end

      context 'and direction is ascending' do
        let(:direction) { 'ascending' }

        it { should eq 'asc' }
      end

      context 'and direction is DESC' do
        let(:direction) { :DESC }

        it { should eq 'desc' }
      end

      context 'and direction is DESCENDING' do
        let(:direction) { :DESCENDING }

        it { should eq 'desc' }
      end

      context 'and direction is desc' do
        let(:direction) { :desc }

        it { should eq 'desc' }
      end

      context 'and direction is descending' do
        let(:direction) { :descending }

        it { should eq 'desc' }
      end

      context 'and direction is a non-valid direction' do
        let(:direction) { 'non-valid' }

        it { should eq direction }
      end
    end

    context 'when format is long' do
      let(:format) { :long }

      context 'and direction is nil' do
        let(:direction) { nil }

        it { should eq '' }
      end

      context 'and direction is ASC' do
        let(:direction) { 'ASC' }

        it { should eq 'ascending' }
      end

      context 'and direction is ASCENDING' do
        let(:direction) { 'ASCENDING' }

        it { should eq 'ascending' }
      end

      context 'and direction is asc' do
        let(:direction) { 'asc' }

        it { should eq 'ascending' }
      end

      context 'and direction is ascending' do
        let(:direction) { 'ascending' }

        it { should eq 'ascending' }
      end

      context 'and direction is DESC' do
        let(:direction) { :DESC }

        it { should eq 'descending' }
      end

      context 'and direction is DESCENDING' do
        let(:direction) { :DESCENDING }

        it { should eq 'descending' }
      end

      context 'and direction is desc' do
        let(:direction) { :desc }

        it { should eq 'descending' }
      end

      context 'and direction is descending' do
        let(:direction) { :descending }

        it { should eq 'descending' }
      end

      context 'and direction is a non-valid direction' do
        let(:direction) { 'non-valid' }

        it { should eq direction }
      end
    end
  end
end
