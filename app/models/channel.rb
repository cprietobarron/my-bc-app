# frozen_string_literal: true

# == Schema Information
#
# Table name: channels
#
#  id                    :bigint           not null, primary key
#  access_token          :string
#  additional_info       :jsonb
#  counts                :jsonb
#  is_token_expired      :boolean          default(FALSE)
#  refresh_token         :string
#  settings              :jsonb
#  status                :integer          default("disabled")
#  token_expires_at      :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  channel_id            :string
#  inventory_sync_job_id :string
#  manual_job_id         :string
#  order_sync_job_id     :string
#  user_id               :bigint           not null
#
# Indexes
#
#  index_channels_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Channel < ApplicationRecord
  include Flippable
  include DefaultableSettings

  encrypts :access_token, :refresh_token

  default_settings sync_direction: nil,
                   sync_mode: nil,
                   sync_include_fields: []

  belongs_to :user
  has_many :sync_records, dependent: :destroy
  has_many :events, dependent: :destroy
  has_one :sync_match, dependent: :destroy

  enum provider: { clover: 1 }
  enum status: { disabled: 0, enabled: 1 }
end
