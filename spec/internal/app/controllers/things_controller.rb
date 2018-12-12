# frozen_string_literal: true

require 'action_set'

class ThingsController < ActionController::Base
  include ActionSet

  def index
    @things = process_set(Thing.all)
    respond_to do |format|
      format.html
      format.json do
        render json: @things.as_json(
          methods: json_extra_methods,
          include: json_extra_models
        )
      end
      format.csv { export_set(@things) }
    end
  end

  def ransack
    p params
    @things = Thing.ransack(params[:q]).result(distinct: true)
    p @things.to_sql
    respond_to do |format|
      format.html
      format.json do
        render json: @things.as_json(
          methods: json_extra_methods,
          include: json_extra_models
        )
      end
      format.csv { export_set(@things) }
    end
  end

  private

  def export_set_columns
    [
      { key: 'hello_world',
        value: 'integer' }
    ]
  end

  def proc_item_string
    ->(item) { item.string }
  end

  def proc_item_only_integer
    ->(item) { item.only.integer }
  end

  def json_extra_methods
    computed_methods = ApplicationRecord::FIELD_TYPES.map { |t| "computed_#{t}" }
    %i[bignum symbol] + computed_methods
  end

  def json_extra_models
    { only: { methods: json_extra_methods }, computed_only: { methods: json_extra_methods } }
  end
end
