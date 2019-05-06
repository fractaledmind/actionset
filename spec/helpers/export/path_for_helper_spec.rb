# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Export::PathForHelper, type: :helper do
  before(:each) do
    allow(helper)
      .to receive(:params)
      .and_return(params.merge(_recall: { controller: 'things', action: 'index' }))
  end
  let(:params) do
    {}
  end

  describe '.export_path_for' do
    subject { helper.export_path_for(format) }

    context 'when format is nil' do
      let(:format) { nil }

      it { should eq '/things?transform%5Bformat%5D=' }
    end

    context 'when format is a string' do
      let(:format) { 'json' }

      it { should eq "/things?transform%5Bformat%5D=#{format}" }
    end

    context 'when format is a symbol' do
      let(:format) { :'csv' }

      it { should eq "/things?transform%5Bformat%5D=#{format}" }
    end
  end
end
