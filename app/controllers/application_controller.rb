# frozen_string_literal: true

# Rails main controller
class ApplicationController < ActionController::API
  after_action :delete_header_for_iframe

  protected

  attr_reader :current_user

  # Extract access-token from headers and sets :current_user reader
  # @return [void]
  def authenticate_user!
    token = request.headers["access-token"]
    return render(json: { error: "Token is missing" }, status: :unauthorized) if token.nil?

    payload = JwtAdapter.decode(token)
    @current_user = User.includes(:channel).find(payload[:sub])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { error: "Not Authorized" }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :unauthorized
  rescue StandardError => e
    Rails.logger.error "[#{self.class}::#{__method__}] Error: #{e.message}"
    render json: {}, status: :internal_server_error
  end

  # DEV ONLY, only for testing an endpoint without requiring a JWT in header.
  # @example basic
  #   before_action { authenticate_user_DEV_ONLY 14 }
  # @param user_id [Integer]
  # @return [void]
  def authenticate_user_DEV_ONLY(user_id) # rubocop:disable Naming/MethodName
    @current_user = User.find(user_id)
  end

  # redirects to a minimum UI in order to show errors when loading app
  # @param message [String] message to show in UI
  # @param details [String] additional details to write in logs but hidden in UI
  # @param exception [StandardError] To write backtrace information to logs
  # @return [void]
  def redirect_to_error(message, details: nil, exception: nil)
    caller_name, line_no = caller&.first&.split(":")&.slice(0..1)
    source = "#{File.basename(caller_name)}:#{line_no}]"
    if exception.is_a?(StandardError)
      logger.fatal "#{source} Error: #{exception.message} => #{exception.backtrace[0..2]}"
    end
    logger.error "#{source} Error: #{message}, #{details}" if details
    redirect_to default_error_url(message)
  end

  # shows error as an alert in the UI
  # @param message [String] message to show in UI
  # @param level [Symbol] :error :warning :info :success
  # @param type [String] custom error type handled by UI request catch code
  # @return [void]
  def return_custom_error(message, level: :error, type: nil)
    payload = {
      message:,
      level:,
      type:
    }
    logger.debug { "Error: #{payload.inspect}" }

    render json: payload, status: :bad_request
  end

  private

  # @return [String]
  def default_error_url(message)
    url = URI.join(Rails.configuration.frontend_url, "error")
    url.query = URI.encode_www_form({ message: })
    url.to_s
  end

  # Fixes the following error:
  #   Refused to display 'https://xyz' in a frame because it set 'X-Frame-Options' to 'sameorigin'.
  # @return [void]
  def delete_header_for_iframe
    response.headers.delete "X-Frame-Options"
  end

  # Use for printing to console information useful only for DEV purposes
  # @return [void]
  def dev_log(msg)
    return unless Rails.env.development?

    logger.debug("\e[33m>> DEV ONLY LOG\e[0m")
    logger.debug(msg)
    logger.debug("\e[33m<< DEV ONLY LOG\e[0m")
  end
end
