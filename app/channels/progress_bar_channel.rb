class ProgressBarChannel < ApplicationCable::Channel
  def subscribed
    stream_from "progress_bar_channel_#{current_user.id}"
    puts '=======subscribed call========='
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
