# frozen_string_literal: true

# Adds required Flipper gem methods to Models
module Flippable
  # @return [String]
  def flipper_id
    "#{self.class}_#{id}"
  end
end
