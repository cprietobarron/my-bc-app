# frozen_string_literal: true

# Channel used for various notifications
class NotificationChannel < ApplicationCable::Channel
  # @return [void]
  def subscribed
    stream_from "notification_channel_#{user_id}"
  end

  # @return [void]
  def unsubscribed; end
end
