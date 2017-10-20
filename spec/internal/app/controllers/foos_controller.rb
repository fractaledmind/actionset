# frozen_string_literal: true

require 'action_set'

class FoosController < ActionController::Base
  include ActionSet

  def index
    # @foos = Foo.all
    # @foos = paginate(sort(filter(Foo.all)))
    @foos = process_set(Foo.all)
    respond_to do |format|
      format.html
      format.json { render json: @foos.to_json }
      format.csv { export_set(@foos) }
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

  def proc_item_assoc_integer
    ->(item) { item.assoc.integer }
  end
end
