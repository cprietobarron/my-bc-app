# frozen_string_literal: true

# Users Controller
class UsersController < ApplicationController
  include Authable

  before_action :authenticate_user!, except: [:authorize]

  # GET /users/me
  # @return [void]
  def me
    render json: current_user
  end

  # POST /users/authorize
  # Receives token generated in auth#load and sets it on headers
  # @return [void]
  def authorize
    params_filtered = params.require(:user).permit(:token)
    token = params_filtered[:token]
    return head :bad_request unless token

    user = decode_user_from_token(token)
    return render(json: { message: "error when authorizing user" }, status: :conflict) unless user

    headers = {
      "access-token" => JwtAdapter.create_auth_token(user.id),
      "token-type" => "Bearer"
    }

    dev_log(headers)

    # update the response header
    response.headers.merge!(headers)
    render json: user
  end
end
