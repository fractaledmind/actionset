# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '#transform_to_sortable_numeric' do
  let(:result) { transform_to_sortable_numeric(value) }

  describe 'converts type to numeric' do
    context 'Integer' do
      let(:value) { rand(10) }

      it { expect(result).to eq value }
    end

    context 'Float' do
      let(:value) { rand }

      it { expect(result).to eq value }
    end

    context 'Complex' do
      let(:value) { Complex(rand(10), rand(10)) }

      it { expect(result).to eq value }
    end

    context 'Rational' do
      let(:value) { Rational(rand(10), rand(1..10)) }

      it { expect(result).to eq value }
    end

    context 'TrueClass' do
      let(:value) { true }

      it { expect(result).to eq 1 }
    end

    context 'FalseClass' do
      let(:value) { false }

      it { expect(result).to eq 0 }
    end

    context 'String' do
      let(:value) { 'aB09ü' }

      it { expect(result).to eq Rational(24_266_512_014_313, 250_000_000_000) }
    end

    context 'Symbol' do
      let(:value) { 'aB09ü'.to_sym }

      it { expect(result).to eq Rational(24_266_512_014_313, 250_000_000_000) }
    end

    context 'Date' do
      let(:value) { Date.new(2000, 12, 25) }

      it { expect(result).to eq 977_720_400_000 }
    end

    context 'Time' do
      let(:value) { Time.new(2000, 12, 25, 11, 30) }

      it { expect(result).to eq 977_761_800_000 }
    end

    # rubocop:disable Style/DateTime
    context 'DateTime' do
      let(:value) { DateTime.new(2000, 12, 25, 11, 30) }

      it { expect(result).to eq 977_743_800_000 }
    end
    # rubocop:enable Style/DateTime
  end

  describe 'retains sortability' do
    let(:sorted_array) { array.sort_by { |x| transform_to_sortable_numeric(x) } }

    context 'array of Strings' do
      let(:array) { %w[a z A Z] }

      it { expect(sorted_array).to eq array.sort }
    end
  end
end
