# frozen_string_literal: true

# Handles Omniauth for Bigcommerce App
class AuthController < ApplicationController
  include Authable

  # GET /auth/:provider/callback
  # PARAMS [code context scope]
  # @return [void]
  def callback
    case provider
    when "bigcommerce"
      result = AuthInteractor::InstallApp.call(auth_hash: auth_hash) if bigcommerce?
      return redirect_to_error(result.error) if result.failure?

      redirect_ui(result.user)
    else
      redirect_to_error("Provider #{provider} is not yet implemented.")
    end
  end

  # GET /load
  # PARAMS [signed_payload]
  # @return [void]
  def load
    load_params = params.permit(:signed_payload, :signed_payload_jwt)
    result = AuthInteractor::LoadApp.call(signed_payload: load_params[:signed_payload],
                                          jwt: load_params[:signed_payload_jwt])
    return redirect_to_error(result.error) if result.failure?

    handle_app_path(result.url, result.user) if result.url.present?

    redirect_ui(result.user)
  end

  # GET /uninstall
  # PARAMS [signed_payload]
  # @return [void]
  def uninstall
    load_result = AuthInteractor::LoadApp.call(signed_payload: params[:signed_payload])
    return head(:unauthorized) if load_result.failure?

    result = AuthInteractor::UninstallApp.call(user: load_result.user)
    logger.info "User #{load_result.user.id} was deleted. #{result.counts.inspect}" if result.success?

    head(:ok)
  end

  protected

  # @param user [User]
  # @return [void]
  def redirect_ui(user)
    app_token = create_app_token(user.id, { exp: 2.minutes.from_now.to_i })
    redirect_to ui_auth_url(app_token)
  end

  # @return [OmniAuth::AuthHash]
  def auth_hash
    request.env["omniauth.auth"]
  end

  # @return [String]
  def provider
    params[:provider]
  end

  # @return [Boolean]
  def bigcommerce?
    params[:provider] == "bigcommerce"
  end

  # @param token [String]
  # @return [String]
  def ui_auth_url(token)
    url = URI.join(Rails.configuration.frontend_url, "auth/", token)
    url.query = URI.encode_www_form({ to: params[:section] }) if params[:section]
    url.to_s
  end

  # Handles app loading actions
  # @param path [String]
  # @param user [User]
  # @return [void]
  def handle_app_path(path, user)
    return unless path == "/auto-connect"

    Rails.logger.debug { ">> Getting 3P-Auth token automatically." }
    result = CloverInteractor::GetAuthToken.call(user: user)
    return_custom_error(result.error) if result.failure?
  end
end
