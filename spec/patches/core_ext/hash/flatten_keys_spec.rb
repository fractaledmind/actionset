# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hash do
  describe '#flatten_keys_to_array' do
    context 'with a nested hash' do
      let(:subject) do
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
      let(:result) do
        {
          [:a] => 'a',
          %i[b c] => 'c',
          %i[b d e] => 'e'
        }
      end
      it 'returns a flat hash with array keys' do
        expect(subject.flatten_keys_to_array).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end

    context 'with an empty hash' do
      let(:subject) do
        {}
      end
      let(:result) do
        {}
      end
      it 'returns a flat hash with array keys' do
        expect(subject.flatten_keys_to_array).to eq(result)
      end
    end

    context 'with a flat hash' do
      let(:subject) do
        {
          a: 'a',
          b: 'b'
        }
      end
      let(:result) do
        {
          [:a] => 'a',
          [:b] => 'b'
        }
      end
      it 'returns a flat hash with array keys' do
        expect(subject.flatten_keys_to_array).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end

    context 'with a nested array' do
      let(:subject) do
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
      let(:result) do
        {
          [:a] => 'a',
          %i[b c] => 'c',
          [:b, :d] => %w[
            x
            y
            z
          ]
        }
      end
      it 'returns a flat hash with array keys' do
        expect(subject.flatten_keys_to_array).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end
  end

  describe '#flatten_keys_to_dotpath' do
    context 'with a nested hash' do
      let(:subject) do
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
      let(:result) do
        {
          'a' => 'a',
          'b.c' => 'c',
          'b.d.e' => 'e'
        }
      end
      it 'returns a flat hash with dotpath keys' do
        expect(subject.flatten_keys_to_dotpath).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_dotpath
        expect(subject).not_to eq(result)
      end
    end

    context 'with an empty hash' do
      let(:subject) do
        {}
      end
      let(:result) do
        {}
      end
      it 'returns a flat hash with dotpath keys' do
        expect(subject.flatten_keys_to_dotpath).to eq(result)
      end
    end

    context 'with a flat hash' do
      let(:subject) do
        {
          a: 'a',
          b: 'b'
        }
      end
      let(:result) do
        {
          'a' => 'a',
          'b' => 'b'
        }
      end
      it 'returns a flat hash with dotpath keys' do
        expect(subject.flatten_keys_to_dotpath).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end

    context 'with a nested array' do
      let(:subject) do
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
      let(:result) do
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
      it 'returns a flat hash with dotpath keys' do
        expect(subject.flatten_keys_to_dotpath).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end
  end

  describe '#flatten_keys_to_html_attribute' do
    context 'with a nested hash' do
      let(:subject) do
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
      let(:result) do
        {
          'a' => 'a',
          'b-c' => 'c',
          'b-d-e' => 'e'
        }
      end
      it 'returns a flat hash with html_attribute keys' do
        expect(subject.flatten_keys_to_html_attribute).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_html_attribute
        expect(subject).not_to eq(result)
      end
    end

    context 'with an empty hash' do
      let(:subject) do
        {}
      end
      let(:result) do
        {}
      end
      it 'returns a flat hash with html_attribute keys' do
        expect(subject.flatten_keys_to_html_attribute).to eq(result)
      end
    end

    context 'with a flat hash' do
      let(:subject) do
        {
          a: 'a',
          b: 'b'
        }
      end
      let(:result) do
        {
          'a' => 'a',
          'b' => 'b'
        }
      end
      it 'returns a flat hash with html_attribute keys' do
        expect(subject.flatten_keys_to_html_attribute).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end

    context 'with a nested array' do
      let(:subject) do
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
      let(:result) do
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
      it 'returns a flat hash with html_attribute keys' do
        expect(subject.flatten_keys_to_html_attribute).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_html_attribute
        expect(subject).not_to eq(result)
      end
    end
  end

  describe '#flatten_keys_to_rails_param' do
    context 'with a nested hash' do
      let(:subject) do
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
      let(:result) do
        {
          'a' => 'a',
          'b[c]' => 'c',
          'b[d][e]' => 'e'
        }
      end
      it 'returns a flat hash with rails_param keys' do
        expect(subject.flatten_keys_to_rails_param).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_rails_param
        expect(subject).not_to eq(result)
      end
    end

    context 'with an empty hash' do
      let(:subject) do
        {}
      end
      let(:result) do
        {}
      end
      it 'returns a flat hash with rails_param keys' do
        expect(subject.flatten_keys_to_rails_param).to eq(result)
      end
    end

    context 'with a flat hash' do
      let(:subject) do
        {
          a: 'a',
          b: 'b'
        }
      end
      let(:result) do
        {
          'a' => 'a',
          'b' => 'b'
        }
      end
      it 'returns a flat hash with rails_param keys' do
        expect(subject.flatten_keys_to_rails_param).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_array
        expect(subject).not_to eq(result)
      end
    end

    context 'with a nested array' do
      let(:subject) do
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
      let(:result) do
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
      it 'returns a flat hash with rails_param keys' do
        expect(subject.flatten_keys_to_rails_param).to eq(result)
      end
      it 'does\'t mutate the subject' do
        subject.flatten_keys_to_html_attribute
        expect(subject).not_to eq(result)
      end
    end
  end
end
