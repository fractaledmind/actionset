# frozen_string_literal: true

require 'action_set'

class FoosController < ActionController::Base
  include ActionSet

  def index
    # @foos = Foo.all
    # @foos = paginate(sort(filter(Foo.all)))
    @foos = process_set(Foo.all)
    render json: @foos.to_json
  end
end
