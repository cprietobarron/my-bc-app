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
# Returns object
class SyncRecordSerializer < ActiveModel::Serializer
  attributes :id, :sync_mode, :status, :progress, :progress_text,
             :has_error, :change_count, :created_at
end
