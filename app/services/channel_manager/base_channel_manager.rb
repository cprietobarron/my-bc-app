# frozen_string_literal: true

# @see https://developer.bigcommerce.com/api-reference/store-management/channels
module ChannelManager
  # Cannot be duplicated channel names, raised if detected
  class ChannelNameDuplicatedError < StandardError
    # @return [self]
    def initialize(channel_name)
      super("Name #{channel_name.inspect} is already being used by another channel.")
    end
  end

  class MultipleMatchesError < StandardError; end

  class ChannelApiError < StandardError; end

  # Manages channel creation
  class BaseChannelManager
    # These methods creates in BaseChannelManager new constants.
    # Change this way if you need to add more child classes.
    class << self
      ChannelData = Struct.new(:name, :type, :platform, :platform_upgrade_from)
      Options = Struct.new(:visible, :listable)

      # @return [void]
      # @param name [String]
      # @param type [String]
      # @param platform [String]
      # @param platform_upgrade_from [String] when upgrading a previous channel with other platform, this field cannot
      #                                       be changed. The current should be deleted and a new created.
      def channel_data(name:, type:, platform:, platform_upgrade_from: nil)
        cd = ChannelData.new(name, type, platform, platform_upgrade_from)
        superclass.const_set(:CHANNEL_DATA, cd.freeze)
      end

      # @param visible [Boolean]
      # @param listable [Boolean]
      # @return [void]
      def options(visible:, listable:)
        opts = Options.new(visible, listable)
        superclass.const_set(:OPTIONS, opts.freeze)
      end

      # @param sections [Hash{String, String}]
      # @return [void]
      def sections(**sections)
        sections_data = sections.each_with_object([]) do |(title, path), result|
          result << { title: title, query_path: path }.freeze
        end
        superclass.const_set(:SECTIONS, sections_data.freeze)
      end
    end

    # Status
    DELETED = "deleted"
    CONNECTED = "connected"
    DISCONNECTED = "disconnected"
    DELETED_STATUSES = %w[deleted terminated].freeze

    # @return [self]
    def initialize(user)
      @user = user
      @client = API::BcClient.new(user.access_token, user.store_hash)
    end

    # @raise [StandardError] if name is already taken
    # @param name [String] Custom channel name
    # @return channel [Hash] Channel
    def create_or_update(name: nil)
      @channels_list = retrieve_channels
      delete_old_channel

      name_to_set = name || CHANNEL_DATA.name
      matching_ch = find_matching_channel
      find_collision_channel(name_to_set, exclude: matching_ch)

      response = matching_ch ? update_channel(matching_ch[:id], name_to_set) : create_new_channel(name_to_set)
      channel = response.body
      raise ChannelApiError, channel[:title] if response.failure?

      channel
    end

    # @param channel_id [String]
    # @return [void]
    def connect(channel_id)
      return unless channel_id

      update_channel_status(channel_id, CONNECTED)
      Rails.logger.debug { "Channel #{channel_id} was connected successfully." }
    end

    # @param channel_id [String]
    # @return [void]
    def disconnect(channel_id)
      return unless channel_id

      update_channel_status(channel_id, DISCONNECTED)
      Rails.logger.debug { "Channel #{channel_id} was disconnected successfully." }
    end

    # @param channel_id [String]
    # @return [void]
    def delete(channel_id)
      return unless channel_id

      update_channel_status(channel_id, DELETED)
      Rails.logger.debug { "Channel #{channel_id} was deleted successfully." }
    end

    private

    attr_reader :user, :client, :channels_list

    # @return [Hash]
    def default_channel_data
      {
        status: CONNECTED,
        is_visible: OPTIONS.visible,
        is_listable_from_ui: OPTIONS.listable,
        config_meta: {
          app: {
            id: Rails.configuration.x.market_app.id,
            sections: SECTIONS
          }
        }
      }
    end

    # :type and :platform are only accepted when CREATING the channel.
    # @return [Hash]
    def new_channel_data
      {
        name: CHANNEL_DATA.name,
        type: CHANNEL_DATA.type,
        platform: CHANNEL_DATA.platform
      }.merge(default_channel_data)
    end

    # @param name [String]
    # @return [API::Response]
    def create_new_channel(name)
      data = new_channel_data
      data[:name] = name
      client.create_channel(data)
    end

    # @param id [Integer]
    # @param name [String]
    # @return [API::Response]
    def update_channel(id, name)
      data = default_channel_data
      data[:name] = name
      client.update_channel(id, data)
    end

    # @return [API::Response]
    def retrieve_channels
      response = client.channels
      raise ChannelApiError, "We could not get the list of your channels. Please try again later." if response.failure?

      response.body
    end

    # @param channel_id [String]
    # @param status [String]
    # @return [Hash]
    def update_channel_status(channel_id, status)
      response = client.update_channel(channel_id, { "status" => status })
      channel = response.body
      raise ChannelApiError, channel[:title] if response.failure?

      channel
    end

    # @raise [StandardError] if multiple channels matches
    # @return [Hash]
    def find_matching_channel
      filtered_channels = find_channel(CHANNEL_DATA.type, CHANNEL_DATA.platform)

      if filtered_channels.size > 1
        collisions = filtered_channels.map { "#{_1[:id]} - #{_1[:name]}".inspect }.join(", ")
        raise MultipleMatchesError, "Multiple matching Channels found: #{collisions} for user #{user&.id}"
      end

      filtered_channels.first
    end

    # @param name [String]
    # @param exclude [Hash]
    # @return [void]
    def find_collision_channel(name, exclude:)
      filtered = exclude ? channels_list.reject { _1[:id] == exclude[:id] } : channels_list
      collision_ch = filtered.find { |ch| ch[:name] == name && DELETED_STATUSES.exclude?(ch[:status]) }
      raise ChannelNameDuplicatedError, name if collision_ch
    end

    # @param type [String]
    # @param platform [String]
    # @return [Array]
    def find_channel(type, platform)
      channels_list.select do |ch|
        ch[:type] == type && ch[:platform] == platform && DELETED_STATUSES.exclude?(ch[:status])
      end
    end

    # if channel_data has platform_upgrade_from name we can't upgrade the channel to new platform type, we need to
    # delete it first.
    # @return [void]
    def delete_old_channel
      return if CHANNEL_DATA.platform_upgrade_from.nil?

      old_channel = find_channel(CHANNEL_DATA.type, CHANNEL_DATA.platform_upgrade_from).first
      return if old_channel.nil?

      delete(old_channel[:id])
      old_channel[:status] = DELETED
      Rails.logger.debug { "Old Channel #{old_channel[:id]} was deleted successfully." }
    end

    # A formatted channel list for debugging purposes
    # @return [Array]
    def chs_pp = channels_list.map { _1.slice(:id, :status, :name, :type, :platform) }.sort_by { _1[:id] }
  end
end
