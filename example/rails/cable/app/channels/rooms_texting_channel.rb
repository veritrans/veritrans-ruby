class RoomsTextingChannel < ApplicationCable::Channel
  def send_message(data)
    chat = Chat.new(
      text: data["message"],
      sender: User.first
    )
    chat.save!
  end

  def subscribed
    stream_from "chat_rooms_channel"
  end
end
