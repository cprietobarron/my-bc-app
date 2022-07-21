# frozen_string_literal: true

# Schedules Sync Record Cleanup
class SyncRecordsCleanupSchedulerWorker < ApplicationWorker
  TIME_BEFORE = 2.months

  # @return [void]
  def perform
    SyncRecord.where("created_at < ?", TIME_BEFORE.ago).delete_all
  end
end
