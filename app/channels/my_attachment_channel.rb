class MyAttachmentChannel < ApplicationCable::Channel
  def subscribed
    stream_from "#{current_user.id}_my_attachment"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
