# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActionSet do
  it 'has a version number' do
    expect(ActionSet::VERSION).not_to be nil
  end
end
