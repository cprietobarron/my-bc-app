# frozen_string_literal: true

# Handles Import/Export sync actions
class ActionsController < ApplicationController
  include Authable

  before_action :authenticate_user!

  # POST /actions/sync
  # @return [void]
  def sync
    head(:ok)
  end

  # POST /actions/cancel
  # @return [void]
  def cancel
    sync = current_user.channel.sync_records.imports_and_exports.in_progress.first

    if sync&.job_id
      Cancelers::SidekiqRedis.cancel!(sync.job_id)
      logger.debug "Job #{sync.job_id} was flagged for cancel!"
    end

    render json: current_user
  end
end
