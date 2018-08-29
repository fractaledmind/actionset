# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pagination::PathForHelper, type: :helper do
  before(:each) do
    allow(helper).to receive(:params).and_return(params.merge(_recall: { controller: 'foos', action: 'index' }))
  end
  let(:params) do
    {}
  end

  describe '.paginate_path_for' do
    subject { helper.paginate_path_for(page) }

    context 'when page is nil' do
      let(:page) { nil }

      it { should eq '/foos?paginate%5Bpage%5D=1' }
    end

    context 'when page is a number' do
      let(:page) { 2 }

      it { should eq "/foos?paginate%5Bpage%5D=#{page}" }
    end

    context 'when page is a string' do
      let(:page) { '2' }

      it { should eq "/foos?paginate%5Bpage%5D=#{page}" }
    end

    context 'when page is a symbol' do
      let(:page) { :'2' }

      it { should eq "/foos?paginate%5Bpage%5D=#{page}" }
    end
  end
end
