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

    if params[:non_atomic]
      logger.info "Non-Atomic Create"
      non_atomic_create
    else
      logger.info "Atomic Create"
      atomic_create
    end
  end

  private
  # This block is the atomic operation, we are altering
  # the messages_requested count and evaluating it's value
  # at the same time
  def atomic_create
    @room.messages_requested.increment do |messages_requested|
      @room.send_message_to_requested_channel(messages_requested)
      if messages_requested <= @room.max_messages
        @room.messages_posted.increment
        @room.send_message_to_posted_channel(@room.messages_posted.value)
        if @message.save
          @room.send_message_to_chat_channel(render_message_to_string)
          render nothing: true
        else
          logger.info @message.errors.inspect
        end
      else
        render nothing: true
      end
    end
  end

  # This is non-atomic, concurrent users can and will retrieve
  # the same count for messages_posted
  # they will get through and violate the max_messages rule
  #
  # * if you place a lock (via lock: true, or .transaction do) on @room,
  # you will not be able to modify
  # that room while people are posting messages, which is undesirable
  # in most applications
  def non_atomic_create
    messages_requested = @room.messages_requested.increment
    @room.send_message_to_requested_channel(@room.messages_requested.value)
    if @room.messages_posted <= @room.max_messages
      if @message.save
        @room.messages_posted.increment
        @room.send_message_to_posted_channel(@room.messages_posted.value)
        @room.send_message_to_chat_channel(render_message_to_string)
        render nothing: true
      else
        logger.info @message.errors.inspect
      end
    else
      render nothing: true
    end
  end

  def render_message_to_string
    render_to_string(partial: '/messages/message', layout: false, locals: {message: @message})
  end

end
