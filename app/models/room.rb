class Room < ActiveRecord::Base
  include Redis::Objects

  has_many :messages
  attr_accessible :name, :max_messages

  counter :messages_requested
  counter :messages_posted

  def requested_channel
    [id, 'requested'].join("-")
  end

  def posted_channel
    [id, 'posted'].join("-")
  end

  def send_to_pubnub(channel, message)
    $pubnub.publish(channel: channel, message: message, callback: ->(m) {Rails.logger.info(m)})
  end

  def send_message_to_requested_channel(message)
    send_to_pubnub(requested_channel, message)
  end

  def send_message_to_posted_channel(message)
    send_to_pubnub(posted_channel, message)
  end
end
