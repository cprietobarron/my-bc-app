# frozen_string_literal: true

module AuthInteractor
  # Handles BigCommerce Uninstall App flow.
  # Deletes the associated user
  class UninstallApp
    include Interactor

    before do
      @channel = context.user.channel
      @counts = {}
    end

    # context:
    #   user [User]
    # @return [Interactor::Context]
    def call # rubocop:disable Metrics/AbcSize
      sync_record_ids = channel.sync_records.pluck(:id)

      run_delete SyncOperation.where(sync_record_id: sync_record_ids)
      run_delete SyncRecord.where(channel_id: channel.id)
      run_delete SyncMatch.where(channel_id: channel.id)
      run_delete Event.where(channel_id: channel.id)
      run_delete Channel.where(id: channel.id)
      run_delete User.where(id: channel.user_id)

      context.counts = counts
    rescue Interactor::Failure; context
    rescue StandardError => e
      Rails.logger.error "[#{self.class}] Error: #{e.message}"
      context.fail!(error: e.message, error_stack: e.backtrace[0..2])
    end

    private

    attr_reader :channel, :counts

    # @param query [ActiveRecord::Relation]
    # @return [void]
    def run_delete(query)
      table_name = query.table_name

      counts[table_name] = query.delete_all
    rescue StandardError => e
      counts[table_name] = e.message if table_name
    end
  end
end
