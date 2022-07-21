# frozen_string_literal: true

# Find events for current user
class EventsController < ApplicationController
  before_action :authenticate_user!

  # GET /events
  # @return [void]
  def index
    pagy, records = pagy(query, items: 10)
    render json: records,
           meta: pagy_metadata(pagy),
           each_serializer: EventsSerializers,
           adapter: :json,
           root: :data
  end

  private

  # @return [ActiveRecord::Relation]
  def query
    query = Event.recent.where(channel_id: current_user.channel.id)
    # Dynamic filters
    query = query.where(event_type: params["types"].split(",")&.map(&:to_sym)) if params["types"].present?

    query
  end
end
