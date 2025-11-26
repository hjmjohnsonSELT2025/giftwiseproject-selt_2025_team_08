class EventAttendeesController < ApplicationController
  before_action :require_login
  before_action :set_event
  before_action :set_event_attendee, only: [:destroy]
  before_action :authorize_creator!, only: [:create, :destroy]

  def create
    @attendee = @event.event_attendees.build(event_attendee_params)
    
    if @attendee.save
      render json: { id: @attendee.id, user_id: @attendee.user_id }, status: :created
    else
      render json: @attendee.errors, status: :unprocessable_content
    end
  end

  def destroy
    @attendee.destroy
    render json: {}, status: :no_content
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_event_attendee
    @attendee = @event.event_attendees.find(params[:id])
  end

  def authorize_creator!
    unless @event.creator_id == current_user.id
      render json: { error: 'Not authorized' }, status: :forbidden
    end
  end

  def event_attendee_params
    params.require(:event_attendee).permit(:user_id)
  end
end
