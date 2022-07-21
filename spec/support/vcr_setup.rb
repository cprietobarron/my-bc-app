# frozen_string_literal: true

require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :faraday
  c.default_cassette_options = { decode_compressed_response: true }
  c.configure_rspec_metadata!
  c.debug_logger = File.open(File.join("tmp", "vcr.log"), "w")
  c.filter_sensitive_data("<BC_CLIENT>") { ENV.fetch("BC_APP_CLIENT_ID", nil) }
  c.filter_sensitive_data("<BC_SECRET>") { ENV.fetch("BC_APP_CLIENT_SECRET", nil) }
  c.filter_sensitive_data("<BC_TOKEN>") { ENV.fetch("BC_TOKEN", nil) }
end
