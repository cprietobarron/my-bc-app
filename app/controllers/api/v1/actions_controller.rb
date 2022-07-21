# frozen_string_literal: true

module Api
  module V1
    # Handles Sync actions
    class ActionsController < Api::V1::ApiController
      before_action :set_user

      # POST /:store_hash/actions/sync
      # @return [void]
      def sync
        head(:ok)
      end
    end
  end
end
