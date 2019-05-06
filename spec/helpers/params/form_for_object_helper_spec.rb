# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Params::FormForObjectHelper, type: :helper do
  before(:each) do
    allow(helper)
      .to receive(:params)
      .and_return(params.merge(_recall: { controller: 'things', action: 'index' }))
  end
  let(:params) do
    {
      filter: {
        string: 'value'
      },
      sort: {
        integer: :desc
      },
      paginate: {
        page: 1
      },
      transform: {
        format: :json
      }
    }
  end

  describe '.form_for_object_from_param' do
    subject { helper.form_for_object_from_param(param, defaults) }

    context 'when param is nil' do
      let(:param) { nil }
      let(:defaults) { {} }

      it { expect(subject.model_name.param_key).to eq param }
    end

    context 'when param is filter' do
      let(:param) { :filter }
      let(:defaults) { {} }

      it { expect(subject.model_name.param_key).to eq param.to_s }
      it { expect(subject.string).to eq params.dig(param, :string).to_s }
    end

    context 'when param is sort' do
      let(:param) { :sort }
      let(:defaults) { {} }

      it { expect(subject.model_name.param_key).to eq param.to_s }
      it { expect(subject.integer).to eq params.dig(param, :integer).to_s }
    end

    context 'when param is paginate' do
      let(:param) { :paginate }
      let(:defaults) { {} }

      it { expect(subject.model_name.param_key).to eq param.to_s }
      it { expect(subject.page).to eq params.dig(param, :page) }
    end

    context 'when param is transform' do
      let(:param) { :transform }
      let(:defaults) { {} }

      it { expect(subject.model_name.param_key).to eq param.to_s }
      it { expect(subject.format).to eq params.dig(param, :format).to_s }
    end

    context 'when param is nil' do
      let(:param) { nil }
      let(:defaults) { { foo: 'bar' } }

      it { expect(subject.model_name.param_key).to eq param }
      it { expect(subject.foo).to eq defaults.dig(:foo).to_s }
    end
  end
end
