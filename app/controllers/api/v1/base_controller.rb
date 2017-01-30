class Api::V1::BaseController < ApplicationController
  include ActionController::ImplicitRender
  respond_to :json
  before_action :authenticate_user_from_token!
  require 'json_web_token'

  def authenticate_user_from_token!
    if claims and session = valid_session?(claims)
      @current_user = session.user
    else
      return render_unauthorized errors: { unauthorized: ["You are not authorized to perform this action."] }
    end
  end

  def jwt_token(user)
    # ex: {data: {id: "tedma4@email.com"}}
    JsonWebToken.encode(user)
  end

  def valid_session?(claims)
    session = Session.find(claims[:data][:session_id])
    if session
      return session
    else
      return false
    end
  end

  protected

  def claims
    # binding.pry
    auth_header = request.headers['HTTP_AUTHORIZATION'] and ::JsonWebToken.decode(auth_header)
  rescue
    nil
  end

  def render_unauthorized(payload)
    render json: payload.merge(response: { code: 401 })
  end

end