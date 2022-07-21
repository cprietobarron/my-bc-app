# frozen_string_literal: true

# SideKiq Sync handler
class ApplicationWorker
  include Sidekiq::Worker

  protected

  attr_reader :user, :provider_sym, :channel

  # initialize the user and channel in the instance to use in the process method
  # @param user_id [Integer]
  # @param provider [String]
  # @return [void]
  def init_instance_variables(user_id, provider)
    @start_time = Time.now.utc
    @user = User.includes(:channel).find(user_id)
    @provider_sym = provider.to_sym
    @channel = user.channel
    @job_id = jid
  end

  # Current implementation is faster than @channel.sync_match.inventory.map(&:symbolize_keys)
  # @return [void]
  def sync_inventory_matches
    @channel.sync_match.inventory.map { _1.transform_keys(&:to_sym) }
  end

  # @return [void]
  def sync_items_matches
    @channel.sync_match.items.deep_symbolize_keys
  end

  # @return [Hash<Key->String>]
  def sync_settings
    @channel.settings
  end
end
