# frozen_string_literal: true

module API
  # Intended to replace the more verbose Faraday::Response object
  Response = Struct.new(:http_method, :url, :status, :success, :body,
                        keyword_init: true) do
    # @param response [#env, #status, #body, Faraday::Response]
    # @param body_subkey [Symbol] (default: nil)
    # @return [self]
    def self.create_from(response, body_subkey: nil)
      new.tap do |s|
        use_direct_body = body_subkey.nil? || !response.success?
        s.http_method = response.env.method
        s.url = CGI.unescape(response.env.url.to_s)
        s.status = response.status
        s.success = response.success?
        s.body = use_direct_body ? response.body : response.body&.fetch(body_subkey)
      end
    end

    # @return [Boolean]
    def success? = success

    # @return [Boolean]
    def failure? = !success
  end
end
