# frozen_string_literal: true

# Helper module to apply filters to query
module FilterManager
  module_function

  # @param query [ActiveRecord]
  # @param options [Hash] hash with multiple filters (filters, sort, page, page+size)
  # @return [ActiveRecord]
  def filter(query, options)
    # Apply filters
    query = apply_filters(query, options[:filters]) if options[:filters]
    # Sort
    query = sort(query, options[:sort]) if options[:sort]
    query
  end

  # @param query [ActiveRecord]
  # @param filters [Hash] hash with field keys and value to filter
  # @return [ActiveRecord]
  def apply_filters(query, filters)
    filters&.each do |key, value|
      values = value.split("|")
      query = query.where("#{key}": values)
    end
    query
  end

  # @param query [ActiveRecord]
  # @param sort [String]
  # @return [ActiveRecord]
  def sort(query, sort)
    matches = sort.match(/^(-)*(.*)/)
    # if there is a "-" before the field, the sort will be descending
    direction = matches[1] ? "DESC" : "ASC"
    query.order("#{matches[2]}": direction)
  end
end
