# frozen_string_literal: true

# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  data           :jsonb
#  event_type     :integer          not null
#  has_error      :boolean          default(FALSE)
#  summary        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  channel_id     :bigint           not null
#  sync_record_id :integer
#
# Indexes
#
#  index_events_on_channel_id  (channel_id)
#  index_events_on_event_type  (event_type)
#
# Foreign Keys
#
#  fk_rails_...  (channel_id => channels.id)
#
class Event < ApplicationRecord
  belongs_to :channel
  validates :event_type, presence: true

  PRETTY_TYPE = {
    "import" => "Import",
    "export" => "Export",
    "inventory_sync" => "Inventory Sync",
    "order_sync" => "Orders Sync",
    "import_inventory" => "Import Inventory",
    "settings" => "Settings",
    "refresh_token" => "Refresh Token",
    "app_enable" => "App Enabled"
  }.freeze

  # 1..49 should be in sync with SyncRecord.sync_mode
  # 50..x should be used for app specific events
  enum event_type: { import: 1, export: 2, inventory_sync: 3, order_sync: 4, import_inventory: 5,
                     settings: 50, refresh_token: 51, app_enable: 52 }

  default_scope { order(updated_at: :desc) }
  scope :recent, -> { where("updated_at > ?", 30.days.ago) }

  # @return [String]
  def event_name
    PRETTY_TYPE[event_type]
  end
end
