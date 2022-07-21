# frozen_string_literal: true

module AuthInteractor
  # Handles BigCommerce Load App flow.
  # validates the payload and return the associated user.
  class LoadApp
    include Interactor

    before do
      @signed_payload = context.signed_payload
      @jwt = decode_payload_jwt(context.jwt) if context.jwt
    end

    # context:
    #   signed_payload [String]
    #   jwt [String]
    # @return [Interactor::Context]
    def call
      payload = use_dev? ? dev_user : bc_payload_parse(signed_payload)
      context.fail!(error: "Invalid payload signature") unless payload

      context.user = User.find_by(store_hash: payload[:store_hash])
      context.url = jwt[:url] if jwt
      context.fail!(error: "User not found. Please reinstall the app.") if context.user.nil?
    rescue Interactor::Failure; context
    rescue StandardError => e
      Rails.logger.error "[#{self.class}] Error: #{e.message}"
      context.fail!(error: e.message, error_stack: e.backtrace[0..2])
    end

    private

    attr_reader :signed_payload, :jwt

    # @return [Boolean]
    def use_dev?
      Rails.env.development? && signed_payload.nil? && Rails.configuration.x.dev_user.present?
    end

    # @return [Hash{Symbol->String}]
    def dev_user
      dev_user = Rails.configuration.x.dev_user
      Rails.logger.debug { "Loaded \e[33m#{dev_user.email}\e[0m DEV user." }
      {
        email: dev_user.email,
        store_hash: dev_user.store_hash,
        token: dev_user.token
      }
    end

    # payload is not a standard JWT
    # @param signed_payload [String] BigCommerce signed payload sent to app
    # @return [Hash,NilClass] Decoded user data from the payload
    def bc_payload_parse(signed_payload)
      context.fail!(error: "Missing payload signature") if signed_payload.blank?

      encoded_json_string, encoded_hmac_signature = signed_payload.split(".")
      payload = Base64.decode64(encoded_json_string)
      signature = Base64.decode64(encoded_hmac_signature)

      # Validate
      expected_signature = OpenSSL::HMAC.hexdigest("sha256", Rails.configuration.x.market_app.client_secret, payload)
      valid = ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
      return unless valid

      JSON.parse(payload, symbolize_names: true)
    end

    # @param token [String]
    # @return [Hash]
    def decode_payload_jwt(token)
      payload, _header = JWT.decode(token, Rails.configuration.x.market_app.client_secret)

      payload.transform_keys(&:to_sym)
    end
  end
end
