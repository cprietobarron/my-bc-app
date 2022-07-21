# frozen_string_literal: true

# Helper module to help format event output based event type.
module EventsHelper
  # @param data [Hash{String->Object}]
  # @return [String]
  def import_format(data)
    import_export_str(data.dig("products", "matched"), data.dig("products", "created"), data.dig("products", "updated"))
  end

  # @param data [Hash{String->Object}]
  # @return [String]
  def export_format(data)
    import_export_str(data.dig("products", "matched"), data.dig("products", "created"), data.dig("products", "updated"))
  end

  # @param data [Hash{String->Object}]
  # @return [String]
  def import_inventory_format(data)
    prod_match = data.dig("products", "matched").to_i
    prod_update = data.dig("products", "updated").to_i
    var_update = data.dig("variants", "updated").to_i
    total_update = var_update + prod_update
    "#{prod_match} products matched. In #{prod_update} products, #{total_update} inventory levels were updated."
  end

  # @param data [Hash{String->Object}]
  # @return [String]
  def inventory_sync_format(data)
    updated = data.dig("inventory", "updated")
    "#{updated || 0} products updated."
  end

  # @param data [Hash{String->Object}]
  # @return [String]
  def order_sync_format(data)
    orders_created = data.dig("orders", "created")
    orders_updated = data.dig("orders", "updated")
    "#{orders_created || 0} orders created, #{orders_updated || 0} orders updated."
  end

  # @param data [Hash{String->Object}]
  # @return [String]
  def settings_format(data)
    result = data.map do |key, value|
      case key
      when "app_enabled" then "App is #{bool_2_text(value)}"
      when "sync_mode" then "Sync Mode changed to <strong>#{value}</strong>"
      when "channel" then "Channel set to #{value}"
      when "run_inventory_sync" then "automatic <strong>Inventory</strong> Update is #{bool_2_text(value)}"
      when "run_order_sync" then "automatic <strong>Order</strong> Update is #{bool_2_text(value)}"
      when "sync_include_fields"
        values = value.any? ? value.join(",") : "nothing"
        "Sync Fields to include <strong>#{values}</strong>"
      else # Generic
        "#{key.humanize} changed to #{value}."
      end
    end
    result.join(", ")
  end

  # @param data [Object]
  # @return [String]
  def refresh_token_format(data)
    data.to_s
  end

  # @param data [Object]
  # @return [String]
  def app_enable_format(data)
    data.to_s
  end

  private

  # @param value [Boolean]
  # @return [String (frozen)]
  def bool_2_text(value) = value ? "enabled" : "disabled"

  # @param matched [Integer]
  # @param created [Integer]
  # @param updated [Integer]
  # @return [String]
  def import_export_str(matched, created, updated)
    "#{matched} products were matched, #{created} products created and #{updated} products updated."
  end
end
