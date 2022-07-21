# frozen_string_literal: true

# Returns object
class EventsSerializers < ActiveModel::Serializer
  include EventsHelper

  attributes :id, :event_type, :summary, :has_error, :data, :sync_record_id

  attribute :event do
    @object.event_name
  end

  attribute :date do
    @object.updated_at
  end

  # @return [String]
  def summary
    formatted = __send__("#{@object.event_type}_format", @object.data)
    return formatted if @object.summary.blank?

    @object.summary.concat("</br>", formatted)
  end
end
