# frozen_string_literal: true

# == Schema Information
#
# Table name: sync_records
#
#  id                  :bigint           not null, primary key
#  change_count        :jsonb            not null
#  has_error           :boolean          default(FALSE)
#  last_successful_run :datetime
#  progress            :integer          default(0)
#  progress_text       :string
#  stats               :jsonb            not null
#  status              :integer          default("created")
#  sync_mode           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  channel_id          :bigint           not null
#  job_id              :string
#
# Indexes
#
#  index_sync_records_on_channel_id  (channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (channel_id => channels.id)
#
class SyncRecord < ApplicationRecord
  belongs_to :channel
  has_many :sync_operation, dependent: :delete_all
  # Should be kept in sync with the Event Model event_type enum at app/models/event.rb
  enum sync_mode: { import: 1, export: 2, inventory_sync: 3, order_sync: 4, import_inventory: 5 }
  enum status: { created: 0, in_progress: 1, completed: 2, canceled: 3 }

  scope :imports_and_exports, -> { where(sync_mode: %i[import export import_inventory]).order(updated_at: :desc) }
  scope :inventory_syncs, -> { where(sync_mode: :inventory_sync).order(updated_at: :desc) }

  # @return [Boolean]
  def error?
    has_error
  end
end
