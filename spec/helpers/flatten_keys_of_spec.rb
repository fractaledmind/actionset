# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '#flatten_keys_of' do
  context '(input, flatten_arrays: false)' do
    let(:result) { flatten_keys_of(input, flatten_arrays: false) }

    context 'with a nested hash' do
      let(:input) do
        {
          a: 'a',
          b: {
            c: 'c',
            d: {
              e: 'e'
            }
          }
        }
      end
      let(:expected) do
        {
          [:a] => 'a',
          %i[b c] => 'c',
          %i[b d e] => 'e'
        }
      end

      it { expect(result).to eq(expected) }
    end

    context 'with an empty hash' do
      let(:input) do
        {}
      end
      let(:expected) do
        {}
      end

      it { expect(result).to eq(expected) }
    end

    context 'with a flat hash' do
      let(:input) do
        {
          a: 'a',
          b: 'b'
        }
      end
      let(:expected) do
        {
          [:a] => 'a',
          [:b] => 'b'
        }
      end

      it { expect(result).to eq(expected) }
    end

    context 'with a nested array' do
      let(:input) do
        {
          a: 'a',
          b: {
            c: 'c',
            d: %w[
              x
              y
              z
            ]
          }
        }
      end
      let(:expected) do
        {
          [:a] => 'a',
          %i[b c] => 'c',
          %i[b d] => %w[
            x
            y
            z
          ]
        }
      end

      it { expect(result).to eq(expected) }
    end
  end

  context '(input, flatten_arrays: true)' do
    let(:result) { flatten_keys_of(input, flatten_arrays: true) }

    context 'with a nested hash' do
      let(:input) do
        {
          a: 'a',
          b: {
            c: 'c',
            d: {
              e: 'e'
            }
          }
        }
      end
      let(:expected) do
        {
          [:a] => 'a',
          %i[b c] => 'c',
          %i[b d e] => 'e'
        }
      end

      it { expect(result).to eq(expected) }
    end

    context 'with an empty hash' do
      let(:input) do
        {}
      end
      let(:expected) do
        {}
      end

      it { expect(result).to eq(expected) }
    end

    context 'with a flat hash' do
      let(:input) do
        {
          a: 'a',
          b: 'b'
        }
      end
      let(:expected) do
        {
          [:a] => 'a',
          [:b] => 'b'
        }
      end

      it { expect(result).to eq(expected) }
    end

    context 'with a nested array' do
      let(:input) do
        {
          a: 'a',
          b: {
            c: 'c',
            d: %w[
              x
              y
              z
            ]
          }
        }
      end
      let(:expected) do
        {
          [:a] => 'a',
          %i[b c] => 'c',
          [:b, :d, 0] => 'x',
          [:b, :d, 1] => 'y',
          [:b, :d, 2] => 'z'
        }
      end

      it { expect(result).to eq(expected) }
    end
  end

  context '(input, flattener:, flatten_arrays: false)' do
    let(:result) { flatten_keys_of(input, flattener: flattener, flatten_arrays: false) }

    describe "keys.join('.')" do
      let(:flattener) { ->(*keys) { keys.join('.') } }

      context 'with a nested hash' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: {
                e: 'e'
              }
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b.c' => 'c',
            'b.d.e' => 'e'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with an empty hash' do
        let(:input) do
          {}
        end
        let(:expected) do
          {}
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a flat hash' do
        let(:input) do
          {
            a: 'a',
            b: 'b'
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b' => 'b'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a nested array' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: %w[
                x
                y
                z
              ]
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b.c' => 'c',
            'b.d' => %w[
              x
              y
              z
            ]
          }
        end

        it { expect(result).to eq(expected) }
      end
    end

    describe "keys.join('-')" do
      let(:flattener) { ->(*keys) { keys.join('-') } }

      context 'with a nested hash' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: {
                e: 'e'
              }
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b-c' => 'c',
            'b-d-e' => 'e'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with an empty hash' do
        let(:input) do
          {}
        end
        let(:expected) do
          {}
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a flat hash' do
        let(:input) do
          {
            a: 'a',
            b: 'b'
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b' => 'b'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a nested array' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: %w[
                x
                y
                z
              ]
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b-c' => 'c',
            'b-d' => %w[
              x
              y
              z
            ]
          }
        end

        it { expect(result).to eq(expected) }
      end
    end

    describe 'keys.map(&:to_s).reduce { |memo, key| memo + "[#{key}]" }' do
      let(:flattener) { ->(*keys) { keys.map(&:to_s).reduce { |memo, key| memo + "[#{key}]" } } }

      context 'with a nested hash' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: {
                e: 'e'
              }
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b[c]' => 'c',
            'b[d][e]' => 'e'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with an empty hash' do
        let(:input) do
          {}
        end
        let(:expected) do
          {}
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a flat hash' do
        let(:input) do
          {
            a: 'a',
            b: 'b'
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b' => 'b'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a nested array' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: %w[
                x
                y
                z
              ]
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b[c]' => 'c',
            'b[d]' => %w[
              x
              y
              z
            ]
          }
        end

        it { expect(result).to eq(expected) }
      end
    end
  end

  context '(input, flattener:, flatten_arrays: true)' do
    let(:result) { flatten_keys_of(input, flattener: flattener, flatten_arrays: true) }

    describe "keys.join('.')" do
      let(:flattener) { ->(*keys) { keys.join('.') } }

      context 'with a nested hash' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: {
                e: 'e'
              }
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b.c' => 'c',
            'b.d.e' => 'e'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with an empty hash' do
        let(:input) do
          {}
        end
        let(:expected) do
          {}
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a flat hash' do
        let(:input) do
          {
            a: 'a',
            b: 'b'
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b' => 'b'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a nested array' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: %w[
                x
                y
                z
              ]
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b.c' => 'c',
            'b.d.0' => 'x',
            'b.d.1' => 'y',
            'b.d.2' => 'z'
          }
        end

        it { expect(result).to eq(expected) }
      end
    end

    describe "keys.join('-')" do
      let(:flattener) { ->(*keys) { keys.join('-') } }

      context 'with a nested hash' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: {
                e: 'e'
              }
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b-c' => 'c',
            'b-d-e' => 'e'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with an empty hash' do
        let(:input) do
          {}
        end
        let(:expected) do
          {}
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a flat hash' do
        let(:input) do
          {
            a: 'a',
            b: 'b'
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b' => 'b'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a nested array' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: %w[
                x
                y
                z
              ]
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b-c' => 'c',
            'b-d-0' => 'x',
            'b-d-1' => 'y',
            'b-d-2' => 'z'
          }
        end

        it { expect(result).to eq(expected) }
      end
    end

    describe 'keys.map(&:to_s).reduce { |memo, key| memo + "[#{key}]" }' do
      let(:flattener) { ->(*keys) { keys.map(&:to_s).reduce { |memo, key| memo + "[#{key}]" } } }

      context 'with a nested hash' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: {
                e: 'e'
              }
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b[c]' => 'c',
            'b[d][e]' => 'e'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with an empty hash' do
        let(:input) do
          {}
        end
        let(:expected) do
          {}
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a flat hash' do
        let(:input) do
          {
            a: 'a',
            b: 'b'
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b' => 'b'
          }
        end

        it { expect(result).to eq(expected) }
      end

      context 'with a nested array' do
        let(:input) do
          {
            a: 'a',
            b: {
              c: 'c',
              d: %w[
                x
                y
                z
              ]
            }
          }
        end
        let(:expected) do
          {
            'a' => 'a',
            'b[c]' => 'c',
            'b[d][0]' => 'x',
            'b[d][1]' => 'y',
            'b[d][2]' => 'z'
          }
        end

        it { expect(result).to eq(expected) }
      end
    end
  end
end
