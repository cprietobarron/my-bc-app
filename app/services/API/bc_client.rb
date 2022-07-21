# frozen_string_literal: true

module API
  # Connects to BigCommerce API
  class BcClient
    BASE_URL = "https://api.bigcommerce.com"
    TAG_ID = 6

    DEFAULT_QUERY_PARAMS = {
      limit: 250,
      page: 1
    }.freeze

    # @param access_token [String]
    # @param store_hash [String]
    # @return [self]
    def initialize(access_token, store_hash)
      raise ArgumentError unless access_token && store_hash

      store_url = URI.join(BASE_URL, "stores/#{store_hash}/")
      @client = Faraday.new(url: store_url, ssl: {}) do |faraday|
        faraday.headers = headers(access_token)
        faraday.request :json
        faraday.response :json, parser_options: { symbolize_names: true }
        faraday.request :gzip
        faraday.request :instrumentation
        faraday.adapter :net_http
      end
    end

    # @see https://developer.bigcommerce.com/api-reference/store-management/channels
    # @return (see #get)
    def channels
      get(__method__, "v3/channels")
    end

    # @return (see #post)
    def create_channel(payload)
      post(__method__, "v3/channels", payload)
    end

    # @return (see #put)
    def update_channel(channel_id, payload)
      put(__method__, "v3/channels/#{channel_id}", payload)
    end

    # @return (see #get)
    def channel_currencies(channel_id)
      get(__method__, "v3/channels/#{channel_id}/currency-assignments")
    end

    # @see https://developer.bigcommerce.com/api-reference/store-management/scripts
    # @param channel_id [Integer]
    # @return (see #get)
    def scripts(channel_id = nil)
      params = {
        "channel_id:in" => channel_id
      }.compact
      get(__method__, "v3/content/scripts", params)
    end

    # @return (see #post)
    def create_script(payload)
      post(__method__, "v3/content/scripts", payload)
    end

    # @return (see #put)
    def update_script(uuid, payload)
      put(__method__, "v3/content/scripts/#{uuid}", payload)
    end

    # @return (see #del)
    def delete_script(uuid)
      del(__method__, "v3/content/scripts/#{uuid}")
    end

    # 3P-Auth get token
    # @param provider [Symbol]
    # @return (see #get)
    def token(provider)
      get(__method__, "v3/partner/credentials/#{provider}")
    end

    # @example basic
    #   # => { redirect_url: "URL" }
    # @param provider [Symbol]
    # @return (see #get)
    def token_initiate(provider)
      params = { redirect_url: "/manage/app/#{Rails.configuration.x.market_app.id}/auto-connect" }
      get_simple(__method__, "v3/partner/credentials/#{provider}/initiate", params)
    end

    # @return (see #get)
    def sites
      get(__method__, "v3/sites")
    end

    # Example
    #   { "id": 6, "channel_id": 0, "name": "Site Verification Tags", "code": "", "enabled": false,
    #     "data_tag_enabled": false, "version": 1, "is_oauth_connected": null }
    # @return (see #get)
    def analytics
      get(__method__, "v3/settings/analytics/#{TAG_ID}")
    end

    # @return (see #put)
    def update_analytics(payload)
      put(__method__, "v3/settings/analytics/#{TAG_ID}", payload)
    end

    # @see https://developer.bigcommerce.com/api-reference/store-management/tax-classes-api/taxes/getalltaxclasses
    # @return (see #get)
    def taxes
      get_v2(__method__, "v2/tax_classes")
    end

    # @see https://developer.bigcommerce.com/api-reference/store-management/shipping-api/shipping-zones/getallshippingzones
    # @return (see #get)
    def shipping_zones
      get_v2(__method__, "v2/shipping/zones")
    end

    # @see https://developer.bigcommerce.com/api-reference/store-management/shipping-api/shipping-method/getshippingmethodszone
    # @return (see #get)
    def shipping_methods(zone_id)
      get_v2(__method__, "v2/shipping/zones/#{zone_id}/methods")
    end

    # @see https://developer.bigcommerce.com/api-reference/store-management/store-information-api/store-information/getstore
    # @return (see #get)
    def store_information
      get_v2(__method__, "v2/store")
    end

    private

    attr_reader :client

    # @param access_token [String]
    # @return [Hash]
    def headers(access_token)
      {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "User-Agent" => "bigcommerce-api-ruby",
        "X-Auth-Client" => Rails.configuration.x.market_app.client_id,
        "X-Auth-Token" => access_token
      }.freeze
    end

    # @param name [Symbol]
    # @param message [String]
    # @return [void]
    def log_error(name, message)
      Rails.logger.error "[#{self.class}.#{name}] Error: #{message}"
    end

    # @param name [Symbol]
    # @param endpoint [String]
    # @param params [Hash]
    # @return [API::Response]
    def get_simple(name, endpoint, params = {})
      response = client.get(endpoint, params)
      log_error(name, response.body.inspect) unless response.success?

      Response.create_from(response)
    end

    # @param name [Symbol]
    # @param endpoint [String]
    # @param additional_params [Hash]
    # @return [API::Response]
    def get(name, endpoint, additional_params = {})
      query_params = DEFAULT_QUERY_PARAMS.merge(additional_params)
      response = client.get(endpoint, query_params)
      unless response.success?
        log_error(name, response.body.inspect)
        return Response.create_from(response)
      end

      Response.create_from(response, body_subkey: :data)
    end

    # Some endpoints are not available on the v3. This does not support pagination
    # @param name [Symbol]
    # @param endpoint [String]
    # @param additional_params [Hash]
    # @return [API::Response]
    def get_v2(name, endpoint, additional_params = {})
      response = client.get(endpoint, additional_params)
      log_error(name, response.body.inspect) unless response.success?

      Response.create_from(response)
    end

    # @param name [Symbol]
    # @param endpoint [String]
    # @return [API::Response]
    def del(name, endpoint)
      response = client.delete(endpoint)
      log_error(name, response.body.inspect) unless response.success?

      Response.create_from(response)
    end

    %i[post put].each do |method_name|
      # @param name [Symbol]
      # @param endpoint [String]
      # @param payload [Hash|Array]
      # @return [API::Response]
      define_method method_name do |name, endpoint, payload|
        send_data(method_name, name, endpoint, payload)
      end
    end

    # @param method [Symbol] :post or :put
    # @param name [Symbol] initial caller method name (usually called from the adapter)
    # @param endpoint [String]
    # @param payload [Hash|Array]
    # @return [API::Response]
    def send_data(method, name, endpoint, payload)
      response = client.__send__(method, endpoint, payload.to_json)
      log_error(name, response.body.inspect) unless response.success?

      Response.create_from(response, body_subkey: :data)
    end
  end
end
