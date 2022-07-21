module ApplicationCable
  # Central App Channel
  class Channel < ActionCable::Channel::Base
    private

    # @return [User]
    def user_id
      params[:user]
    end
  end
end
