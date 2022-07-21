# frozen_string_literal: true

module Api
  module V1
    # Handles Info
    class InfoController < Api::V1::ApiController
      before_action :set_user

      # GET /:store_hash/info
      # @return [void]
      def index
        info = {
          is_installed: user.present?,
          is_authenticated: user.channel&.access_token.present?
        }
        add_channel_info(info)

        json_response(info)
      end

      # GET /:store_hash/matches
      # @return [void]
      def matches
        matches = user.channel&.sync_match&.as_json || {}
        matches.store :cache_exist, user.channel&.sync_match.present?

        json_response(matches)
      end

      private

      # @param info [Hash]
      # @return [void]
      def add_channel_info(info)
        return if user.channel.nil?

        info.store :is_token_expired, user.channel.is_token_expired
        info.store :channel_id, user.channel.channel_id
        info.store :settings, user.channel.settings
        info.store :additional_info, user.channel.additional_info
      end
    end
  end
end
