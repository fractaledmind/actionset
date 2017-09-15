# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /foos', type: :request do
  let(:foo) { FactoryGirl.create(:foo) }
  let(:others) { FactoryGirl.create_list(:foo, 2) }
  let(:params) { {} }

  before(:each) do
    get foos_path, params: params, headers: {}
  end

  it { expect(response).to have_http_status :ok }
end
