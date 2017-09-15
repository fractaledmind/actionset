# frozen_string_literal: true

require 'action_set'

class FoosController < ActionController::Base
  include ActionSet

  def index
    # @users = Foo.all
    # @users = paginate(sort(filter(Foo.all)))
    @users = process_set(Foo.all)
    render json: @users.to_json
  end
end
