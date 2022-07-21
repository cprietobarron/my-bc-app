# frozen_string_literal: true

# == Schema Information
#
# Table name: sync_operations
#
#  id             :bigint           not null, primary key
#  action         :integer          not null
#  data           :jsonb
#  error_message  :string
#  item_type      :integer
#  name           :string
#  original_type  :integer
#  provider       :integer
#  step           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  item_id        :string
#  match_id       :string
#  parent_id      :string
#  sync_record_id :bigint           not null
#
# Indexes
#
#  index_sync_operations_on_sync_record_id             (sync_record_id)
#  index_sync_operations_on_sync_record_id_and_action  (sync_record_id,action)
#
# Foreign Keys
#
#  fk_rails_...  (sync_record_id => sync_records.id) ON DELETE => cascade
#
# Returns object
class SyncOperationSerializer < ActiveModel::Serializer
  attributes :id, :item_id, :match_id, :name, :item_type,
             :error_message, :provider, :step, :parent_id, :data,
             :action, :original_type, :sync_record_id
end
