# frozen_string_literal: true

# Channel used for changing the progress bar
class ActivityChannel < ApplicationCable::Channel
  # @return [void]
  def subscribed
    stream_from "activity_channel_#{user_id}"
  end

  # @return [void]
  def unsubscribed; end
end
