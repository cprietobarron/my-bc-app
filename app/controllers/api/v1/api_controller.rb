# frozen_string_literal: true

module Api
  module V1
    # Top Level Api Controller
    class ApiController < ActionController::API
      include ActionController::HttpAuthentication::Basic::ControllerMethods

      http_basic_authenticate_with name: Rails.configuration.x.api.username,
                                   password: Rails.configuration.x.api.password

      protected

      attr_reader :user

      # @return [Object]
      def set_user
        @user = User.find_by(store_hash: params[:store_hash])
        error_response("Store #{params[:store_hash]} was not found.") if user.nil?
      end

      # @param object [Object]
      # @param status [Symbol]
      # @return [void]
      def json_response(object, status = :ok)
        render json: object, status: status
      end

      # @param message [String] message to show
      # @return [void]
      def error_response(message)
        render json: { error: message }, status: :bad_request
      end

      rescue_from(StandardError) do |e|
        render json: { error: e.message, stack: e.backtrace.grep_v(/gems/) }, status: :bad_request
      end
    end
  end
end
