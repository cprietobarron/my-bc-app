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
class SyncOperation < ApplicationRecord
  belongs_to :sync_record

  enum item_type: { product: 1, variant: 2, category: 3, item: 4, item_group: 5 }, _suffix: true
  enum original_type: { product: 1, variant: 2, category: 3, item: 4, item_group: 5 }, _prefix: :original
  enum provider: { bigcommerce: 1, clover: 2 }
  enum action: { new: 1, update: 2, error: 3, warning: 4, match: 5 }, _suffix: true
  enum step: { fetch: 1, digest: 2, match: 3, compare: 4, pusher: 5 }
  class << self
    # @param result [CloverSync::Result]
    # @param errors [Array<Hash>]
    # @param sync_record_id [Integer]
    # @return [Array]
    def build_sync_operations(result, errors, sync_record_id)
      @sync_record_id = sync_record_id

      objects = []
      # Build changes
      result.changes&.each do |change|
        objects.push(get_object(change))
      end
      # Build matches
      result.inventory_matches&.to_a&.each do |match|
        match_object = build_match_object(match)
        objects.push(get_object(match_object))
      end
      # Build errors
      errors&.each do |error|
        objects.push(get_object(error))
      end
      objects
    end

    # @param match [Hash{Symbol->Symbol}]
    # @return [Hash{Symbol->Symbol}]
    def build_match_object(match)
      {
        item_id: match.base[:id],
        action: :match,
        name: match.base[:name],
        item_type: match.base[:original_type],
        original_type: match.ext[:original_type],
        provider: :bigcommerce,
        data: {
          price: match.ext[:price],
          sku: match.ext[:sku]
        },
        parent_id: match.base[:product_id],
        match_id: match.ext[:id],
        step: :match
      }
    end

    # @param data [Hash{Symbol->Symbol}]
    # @return [Hash{Symbol->Hash}]
    def get_object(data) # rubocop:disable Metrics/MethodLength
      data = data.to_h unless data.is_a?(Hash)
      now = Time.zone.now
      {
        sync_record_id: @sync_record_id,
        created_at: now,
        updated_at: now,
        data: data[:data] || {},
        name: data[:name],
        item_id: data[:item_id] || data[:id],
        item_type: data[:item_type] || data[:type],
        action: data[:action],
        match_id: data[:match_id],
        provider: data[:provider],
        parent_id: data[:parent_id],
        error_message: data[:error_message],
        original_type: data[:original_type],
        step: data[:step]
      }
    end
  end
end
