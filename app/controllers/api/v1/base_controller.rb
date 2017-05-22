class Api::V1::BaseController < ApplicationController
  include ActionController::ImplicitRender
  respond_to :json
  before_action :authenticate_user_from_token!
  require 'json_web_token'

  def authenticate_user_from_token!
    if claims and session = valid_session?(claims)
      @current_user = session.first.user
    else
      render json: {errors: { unauthorized: ["You can't do that"] }}, status: 401
    end
  end

  def jwt_token(user)
    # ex: {data: {id: "tedma4@email.com"}}
    JsonWebToken.encode(user)
  end

  def valid_session?(claims)
    session = Session.where(user_id: claims[:data][:user_id])
    if session
      return session
    else
      return false
    end
  end

  protected

  def claims
    auth_header = request.headers['HTTP_AUTHORIZATION'] and ::JsonWebToken.decode(auth_header)
  rescue
    nil
  end

  # def super_special_request
  #   if request.header['X-AUTHORIZATION']
  #     JsonWebToken.decode
  # end

end