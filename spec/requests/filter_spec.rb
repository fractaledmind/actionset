# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'a successful filter' do
  it { expect(results.map { |f| f['id'] }).to eq [matching_item.id] }
end

RSpec.describe 'GET /foos?filter', type: :request do
  before(:all) do
    @foo_1 = FactoryBot.create(:foo, assoc: FactoryBot.create(:assoc))
    @foo_2 = FactoryBot.create(:foo, assoc: FactoryBot.create(:assoc))
    @active_set = ActiveSet.new(Foo.all)
  end
  after(:all) { Foo.delete_all }

  context '.json' do
    let(:results) { JSON.parse(response.body) }

    before(:each) do
      get foos_path(format: :json), params: { filter: instructions }, headers: {}
    end

    ApplicationRecord::FIELD_TYPES.each do |type|
      context "with #{type.upcase} type" do
        [1, 2].each do |foo_id|
          context "matching @foo_#{foo_id}" do
            let(:matching_item) { instance_variable_get("@foo_#{foo_id}") }

            %W[
              #{type}
              computed_#{type}
              assoc.#{type}
              assoc.computed_#{type}
              computed_assoc.#{type}
              computed_assoc.computed_#{type}
            ].each do |path|
              context "{ #{path}: }" do
                let(:instructions) do
                  {
                    path => path.split('.').reduce(matching_item) { |obj, m| obj.send(m) }
                  }
                end

                it_behaves_like 'a successful filter'
              end
            end
          end
        end
      end
    end

    ApplicationRecord::FIELD_TYPES.combination(2).each do |type_1, type_2|
      context "with #{type_1.upcase} and #{type_2.upcase} types" do
        [1, 2].each do |foo_id|
          context "matching @foo_#{foo_id}" do
            let(:matching_item) { instance_variable_get("@foo_#{foo_id}") }

            %W[
              #{type_1}
              #{type_2}
              computed_#{type_1}
              computed_#{type_2}
              assoc.#{type_1}
              assoc.#{type_2}
              assoc.computed_#{type_1}
              assoc.computed_#{type_2}
              computed_assoc.#{type_1}
              computed_assoc.#{type_2}
              computed_assoc.computed_#{type_1}
              computed_assoc.computed_#{type_2}
            ].combination(2).each do |path_1, path_2|
              context "{ #{path_1}:, #{path_2} }" do
                let(:instructions) do
                  {
                    path_1 => path_1.split('.').reduce(matching_item) { |obj, m| obj.send(m) },
                    path_2 => path_2.split('.').reduce(matching_item) { |obj, m| obj.send(m) }
                  }
                end

                it_behaves_like 'a successful filter'
              end
            end
          end
        end
      end
    end

    context 'on a SCOPE' do
      context 'matching @foo_1' do
        let(:matching_item) { @foo_1 }

        context '{ string_starts_with: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3]
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ string_ends_with: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1]
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_starts_with: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_starts_with': matching_item.assoc.string[0..3]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_ends_with: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_ends_with': matching_item.assoc.string[-3..-1]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_starts_with: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_starts_with': matching_item.computed_assoc.string[0..3]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_ends_with: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_ends_with': matching_item.computed_assoc.string[-3..-1]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end
      end

      context 'matching @foo_2' do
        let(:matching_item) { @foo_2 }

        context '{ string_starts_with: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3]
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ string_ends_with: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1]
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_starts_with: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_starts_with': matching_item.assoc.string[0..3]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_ends_with: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_ends_with': matching_item.assoc.string[-3..-1]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_starts_with: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_starts_with': matching_item.computed_assoc.string[0..3]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_ends_with: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_ends_with': matching_item.computed_assoc.string[-3..-1]
              }
            }
          end

          it_behaves_like 'a successful filter'
        end
      end
    end

    context 'on a SCOPE and with STRING type' do
      context 'matching @foo_1' do
        let(:matching_item) { @foo_1 }

        context '{ string_starts_with:, string: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3],
              string: matching_item.string
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ string_ends_with:, string: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1],
              string: matching_item.string
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_starts_with': matching_item.assoc.string[0..3],
                string: matching_item.assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_ends_with': matching_item.assoc.string[-3..-1],
                string: matching_item.assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_starts_with': matching_item.computed_assoc.string[0..3],
                string: matching_item.computed_assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_ends_with': matching_item.computed_assoc.string[-3..-1],
                string: matching_item.computed_assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end
      end

      context 'matching @foo_2' do
        let(:matching_item) { @foo_2 }

        context '{ string_starts_with:, string: }' do
          let(:instructions) do
            {
              'string_starts_with': matching_item.string[0..3],
              string: matching_item.string
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ string_ends_with:, string: }' do
          let(:instructions) do
            {
              'string_ends_with': matching_item.string[-3..-1],
              string: matching_item.string
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_starts_with': matching_item.assoc.string[0..3],
                string: matching_item.assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ assoc: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              assoc: {
                'string_ends_with': matching_item.assoc.string[-3..-1],
                string: matching_item.assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_starts_with:, string: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_starts_with': matching_item.computed_assoc.string[0..3],
                string: matching_item.computed_assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end

        context '{ computed_assoc: { string_ends_with:, string: } }' do
          let(:instructions) do
            {
              computed_assoc: {
                'string_ends_with': matching_item.computed_assoc.string[-3..-1],
                string: matching_item.computed_assoc.string
              }
            }
          end

          it_behaves_like 'a successful filter'
        end
      end
    end
  end
end
