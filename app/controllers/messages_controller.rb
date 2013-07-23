class MessagesController < ApplicationController
  def new
  end

  def show
    @message = Message.find(params[:id])
  end

  def index
    # This only makes sense in the context of a room
    @room = Room.find(params[:room_id])
    @messages = @room.messages
  end

  def create
    @room = Room.find(params[:message][:room_id])
    @message = Message.new(params[:message])

    @room.messages_requested.increment do |messages_requested|
      @room.send_message_to_requested_channel(messages_requested)
      if messages_requested <= @room.max_messages
        @room.messages_posted.increment
        @room.send_message_to_posted_channel(@room.messages_posted.value)
        if @message.save
          message = render_to_string(partial: '/messages/message', layout: false, locals: {message: @message})
          @room.send_message_to_chat_channel(message)
          render nothing: true
        else
          logger.info @message.errors.inspect
        end
      else
        render nothing: true
      end
    end
  end

end
