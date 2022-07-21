# frozen_string_literal: true

# == Schema Information
#
# Table name: sync_matches
#
#  id         :bigint           not null, primary key
#  categories :jsonb            not null
#  inventory  :jsonb            not null
#  products   :jsonb            not null
#  variants   :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  channel_id :bigint           not null
#
# Indexes
#
#  index_sync_matches_on_channel_id  (channel_id)
#
# Foreign Keys
#
#  fk_rails_...  (channel_id => channels.id)
#
class SyncMatch < ApplicationRecord
  belongs_to :channel
end
