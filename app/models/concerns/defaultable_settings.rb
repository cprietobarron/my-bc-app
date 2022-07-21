# frozen_string_literal: true

# Adds missing keys in Settings using class' DEFAULT_SETTINGS hash
# Model MUST use default_settings method
module DefaultableSettings
  extend ActiveSupport::Concern

  # @example usage
  #   include DefaultableSettings
  #   default_settings sync_direction: "export"
  class_methods do
    # @param options [Hash{String,Symbol->String}]
    # @return [void]
    def default_settings(**options)
      defaults = options.transform_keys(&:to_s).freeze
      const_set(:DEFAULT_SETTINGS, defaults)

      store_accessor :settings, defaults.keys, prefix: true
    end
  end

  included do
    after_initialize :set_default_settings
  end

  private

  # @return [void]
  def set_default_settings
    if settings
      self.class::DEFAULT_SETTINGS.each { |key, value| settings[key] = value unless settings.key?(key) }
    else
      self.settings = self.class::DEFAULT_SETTINGS.dup
    end
  end
end
