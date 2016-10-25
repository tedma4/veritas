#lib/json_web_token.rb
require 'jwt'

class JsonWebToken
  def self.encode(payload, expiration = 24.hours.from_now)
    payload = payload.dup
    # payload['exp'] = expiration.to_i
    # Setting a json web_token secret for now
    Rails.application.secrets[:json_web_token_secret] = 'qwerty2345qwert'
    JWT.encode({this: payload}, Rails.application.secrets.json_web_token_secret)
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.secrets.json_web_token_secret)
  end
end