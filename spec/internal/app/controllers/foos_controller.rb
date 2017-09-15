# frozen_string_literal: true

class FoosController < ActionController::Base
  include ActionSet

  def index
    @users = Foo.all
    # @users = paginate(sort(filter(User.all)))
    # @users = process(User.all)
    render json: @users.to_json
  end
end
