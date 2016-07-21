  #app/controllers/api/base_controller.rb
  class Api::BaseController < ApplicationController
  include ActionController::ImplicitRender
  respond_to :json

  before_filter :authenticate_user_from_token!

    def authenticate_user_from_token!
      if claims and user = User.find_by(email: claims[0]['user'])
        @current_user = user
      else
        return render_unauthorized errors: { unauthorized: ["You are not authorized perform this action."] }
      end
    end

  protected

    def claims
      auth_header = request.headers['Authorization'] and
        token = auth_header.split(' ').last and
        ::JsonWebToken.decode(token)
    rescue
      nil
    end

    def jwt_token user
      JsonWebToken.encode('user' => user.email)
    end

    def render_unauthorized(payload)
      render json: payload.merge(response: { code: 401 })
    end

  end