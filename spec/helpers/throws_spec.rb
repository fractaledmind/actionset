# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '#throws?' do
  it { expect(throws?(StandardError) { fail }).to be true }
  it { expect(throws?(NameError) { fail NameError }).to be true }
  it { expect(throws?(NoMethodError) { fail NameError }).to be false }
  it { expect(throws?(StandardError) { nil }).to be false }
end
