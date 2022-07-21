# frozen_string_literal: true

# SyncRecord model
class SyncRecordsController < ApplicationController
  include FilterManager

  before_action :authenticate_user!

  # GET /events
  # @return [void]
  def index; end

  # @return [void]
  def show
    render json: query_sync_record(permitted_params)
  end

  # @return [void]
  def sync_operations
    sync_record = SyncRecord.find(params[:sync_record_id])
    query = SyncOperation.where(sync_record_id: params[:sync_record_id])

    options = {
      page: params[:page],
      page_size: params[:page_size],
      filters: params[:filters],
      sort: params[:sort]
    }

    # Apply filters based on options
    query = FilterManager.filter(query, options)

    meta, records = paginate(query, options)

    render json: {
      sync_record: sync_record,
      sync_operations: records,
      meta: meta
    }
  end

  private

  # @return [ActionController::Parameters]
  def permitted_params
    params.permit(:id)
  end

  # @return [ActiveRecord::Relation]
  def query_sync_record(filters)
    SyncRecord.find(filters[:id])
  end

  # @return [Pagy, ActiveRecord]
  def paginate(query, options)
    # Paginate
    paginate = options[:page] && options[:page_size]
    if paginate
      pagy, records = pagy(query, items: options[:page_size], page: options[:page], max_items: nil)
      meta = pagy_metadata(pagy)
    else
      records = query
    end

    [meta, records]
  end
end
