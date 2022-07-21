# frozen_string_literal: true

# Channels Controller
class ChannelsController < ApplicationController
  before_action :authenticate_user!

  # POST /channels/settings
  # Used in OnBoarding step 3 & settings page
  # @return [void]
  def settings
    SettingsService.new(current_user).save_settings(sanitized_params.to_h)

    render json: current_user
  rescue StandardError => e
    type = e.class.to_s.underscore
    Rails.logger.error "[#{__method__}] Error, #{e.message}"
    return_custom_error(e.message, type: type)
  end

  # POST /channels/requirements
  # Used in OnBoarding step 2
  #   result is sent by ActionCable handled in Listeners::NotificationListener
  # @return [void]
  def requirements
    head(:ok)
  end

  # POST /channels/connect
  # Used in OnBoarding step 1
  #   result is sent by ActionCable handled in Listeners::NotificationListener
  # @return [void]
  def connect
    head(:ok)
  end

  # POST /channels/disable
  # @return [void]
  def disable
    SettingsService.new(current_user).disable_app

    render json: current_user
  end

  # POST /channels/enable
  # @return [void]
  def enable
    SettingsService.new(current_user).enable_app

    render json: current_user
  end

  private

  # Only allow a list of trusted parameters through.
  # @return [void]
  def sanitized_params
    params.require(:channel)
          .require(:settings).permit(:channel_name, :sync_direction, :sync_mode,
                                     :run_inventory_sync, :run_order_sync, sync_include_fields: [])
  end
end
