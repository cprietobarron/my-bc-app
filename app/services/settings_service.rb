# frozen_string_literal: true

# Handles changes to settings in channel model and creates an Event record with the changes
class SettingsService
  # @return [self]
  def initialize(user)
    @user = user
    @channel = user.channel
  end

  # @param new_settings [Hash]
  # @return [void]
  def save_settings(new_settings)
    new_settings[:sync_direction]&.downcase!
    old_settings = channel.settings.dup

    changes = compare_settings(old_settings, new_settings)
    return if changes.empty?

    update_orders_date if changes["run_order_sync"]
    changes.each { |key, value| channel.settings[key] = value }

    need_channel_update = channel.channel_id.blank? || changes[:channel_name]

    if need_channel_update
      result = BcInteractor::ActivateChannel.call(user: user, channel_name: changes[:channel_name])
      Rails.logger.error("Failed to connect channel") if result.failure?
    end

    save_event(changes) if channel.save
  end

  # @return [void]
  def disable_app
    ActiveRecord::Base.transaction do
      channel.update(status: :disabled)
      save_event({ "app_enabled" => false })
    end
    ChannelManager::Clover.new(user).disconnect(channel.channel_id)
  end

  # @return [void]
  def enable_app
    ActiveRecord::Base.transaction do
      channel.update(status: :enabled)
      save_event({ "app_enabled" => true })
    end
    ChannelManager::Clover.new(user).connect(channel.channel_id)
  end

  private

  attr_reader :user, :channel

  # @param changes [Hash]
  # @return [void]
  def save_event(changes)
    Event.create(data: changes, channel: channel, event_type: :settings)
  end

  # @param current [Hash] Current settings
  # @param new [Hash] New settings
  # @return [Hash] Contains configuration changes
  def compare_settings(current, new)
    new.reject { |key, value| current[key] == value }
  end

  # @return [void]
  def update_orders_date
    sync_record = SyncRecord.where(sync_mode: :order_sync, channel: channel).first_or_create
    sync_record.update(last_successful_run: Time.now.utc)
  end
end
