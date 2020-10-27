# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActionSet::AttributeValue do
  before(:all) do
    @thing = FactoryBot.create(:thing)
  end

  describe '#cast' do
    ApplicationRecord::FIELD_TYPES.each do |type|
      it "casts into #{type} when passed type class" do
        type_value = @thing.public_send(type)
        string_value = type_value.to_s
        attribute_value = ActionSet::AttributeValue.new(string_value)
        cast_value = attribute_value.cast(to: type_value.class)

        expect(cast_value).to eql type_value
      end

      it "casts into #{type} when passed no type class" do
        type_value = @thing.public_send(type)
        string_value = type_value.to_s
        attribute_value = ActionSet::AttributeValue.new(string_value)
        cast_value = attribute_value.cast(to: Module.new)

        expect(cast_value).to eql string_value
      end
    end
  end
end
