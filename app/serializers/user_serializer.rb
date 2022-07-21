# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  access_token :string
#  email        :string           not null
#  scope        :string
#  store_hash   :string           not null
#  uid          :string
#  username     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  store_id     :integer
#
# Indexes
#
#  index_users_on_store_hash            (store_hash)
#  index_users_on_store_hash_and_email  (store_hash,email) UNIQUE
#
# Transform the User to expected format (React App)
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :store_hash, :uid

  attribute :onboarding do
    {
      is_connected: onboarding_connected?,
      is_settings_set: onboarding_settings?,
      is_synced: onboarding_synced?
    }
  end

  attribute :is_onboarding_complete do
    # Reverse order to fail fast if incomplete
    onboarding_synced? && onboarding_settings? && onboarding_connected?
  end

  attribute :settings do
    @object.channel&.settings
  end

  attribute :additional_info do
    @object.channel&.additional_info
  end

  # true if current_user has disabled automatic 5 minute inventory sync
  attribute :disabled do
    @object.channel&.disabled?
  end

  attribute :sync_record do
    @object.channel&.sync_records&.imports_and_exports&.first
  end

  attribute :sync_in_progress do
    manual_job?
  end

  private

  # @return [Boolean]
  def manual_job?
    @object.channel&.manual_job_id.present?
  end

  # @return [Boolean]
  def onboarding_connected?
    @object.channel&.access_token.present?
  end

  # @return [Boolean]
  def onboarding_settings?
    @object.channel&.settings&.dig("sync_direction").present?
  end

  # @return [Boolean]
  def onboarding_synced?
    @object.channel&.events&.where(event_type: %w[import export])&.any?
  end
end
