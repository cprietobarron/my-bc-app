# frozen_string_literal: true

module AuthInteractor
  # Handles BigCommerce Install App flow
  class InstallApp
    include Interactor

    before do
      validate_auth_hash
      @user_hash = map_user(context.auth_hash)
    end

    # context:
    #   auth_hash [OmniAuth::AuthHash] object from BigCommerce OAuth
    # @return [Interactor::Context]
    def call
      user = nil
      ApplicationRecord.transaction do
        user = User.find_or_create_by!(user_hash.slice(:store_hash, :email))
        user.create_channel!
        user.update!(user_hash.slice(:uid, :username, :access_token, :scope))
      end

      context.user = user
    rescue Interactor::Failure; context
    rescue StandardError => e
      msg = e.is_a?(PG::UniqueViolation) ? "Already installed. Please uninstall first" : e.message

      Rails.logger.error "[#{self.class}] Error: #{msg}"
      context.fail!(error: msg, error_stack: e.backtrace[0..2])
    end

    private

    attr_reader :user_hash

    # @return [void]
    def validate_auth_hash
      context.fail!(error: "Did not receive auth credentials") unless context.auth_hash
      context.fail!(error: "Received invalid auth credentials") unless context.auth_hash.dig(:extra, :context)
    end

    # @return [Hash]
    def map_user(hash)
      {
        uid: hash[:uid],
        username: hash.dig(:info, :name),
        email: hash.dig(:info, :email),
        store_hash: hash.dig(:extra, :context).split("/").last,
        access_token: hash.dig(:credentials, :token).token,
        scope: hash.dig(:extra, :scopes)
      }
    end
  end
end
