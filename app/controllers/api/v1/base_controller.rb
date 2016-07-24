class Api::V1::BaseController < ApplicationController
  include ActionController::ImplicitRender
  respond_to :json
  before_action :authenticate_user_from_token!
  require 'json_web_token'

  def authenticate_user_from_token!
    if claims and user = User.find_by(email: claims[0]['user'])
      @current_user = user
    else
      return render_unauthorized errors: { unauthorized: ["You are not authorized perform this action."] }
    end
  end

  def jwt_token(user)
    JsonWebToken.encode(user.email)
  end

  protected

  def claims
    auth_header = request.headers['Authorization'] and
      token = auth_header.split(' ').last and
      ::JsonWebToken.decode(token)
  rescue
    nil
  end

  def render_unauthorized(payload)
    render json: payload.merge(response: { code: 401 })
  end

end