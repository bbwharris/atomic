class RoomsController < ApplicationController
  def new
    @room = Room.new
  end

  def show
    @room = Room.find(params[:id])
  end

  def index
    @room = Room.new
    @rooms = Room.all
  end

  def create
    @room = Room.new(params[:room])
    if @room.save
      redirect_to room_url(@room), notice: "Your room has been created! Start Chatting."
    else
      flash[:alert] = "Unable to save that room"
      render :new
    end
  end

end
