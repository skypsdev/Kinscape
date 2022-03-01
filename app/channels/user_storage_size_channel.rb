class UserStorageSizeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_storage_size_channel_#{current_user.id}"
    puts '=======user storage========='
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
