class ChatBroadcasterJob < ApplicationJob
   queue_as :default

   def perform(chat)
      ActionCable.server.broadcast "chat_rooms_channel",
         chat: render_message(chat)
   end

   private

   def render_message(chat)
      ChatsController.render partial: 'chats/chat',
         locals: {chat: chat}
   end
end
