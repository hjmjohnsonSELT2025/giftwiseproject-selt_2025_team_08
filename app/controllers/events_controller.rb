class EventsController < ApplicationController
  before_action :require_login
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authorize_creator!, only: [:edit, :update, :destroy]
  before_action :authorize_viewer!, only: [:show]

  def index
    @events = Event
      .left_joins(:event_attendees, :recipients)
      .where(
        "events.creator_id = ? OR event_attendees.user_id = ? OR (recipients.first_name = ? AND recipients.last_name = ?)",
        current_user.id, current_user.id, current_user.first_name, current_user.last_name
      )
      .distinct
      .order(created_at: :desc)
  end

  def show
    @event = Event.includes(:attendees, :recipients).find(params[:id])
    @is_creator = @event.creator_id == current_user.id
    @is_attendee = @event.attendees.include?(current_user)
    @is_recipient = @event.recipients.exists?(
      first_name: current_user.first_name,
      last_name: current_user.last_name
    )
    @can_see_gift_section = @is_creator || @is_attendee || @is_recipient
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.creator_id = current_user.id
    if @event.save
      @event.attendees << current_user unless @event.attendees.include?(current_user)
      
      if params[:event][:attendee_ids].present?
        attendee_ids = params[:event][:attendee_ids].reject(&:blank?)
        attendee_ids.each do |user_id|
          user = User.find_by(id: user_id)
          @event.attendees << user if user && !@event.attendees.include?(user)
        end
      end
      
      if params[:event][:recipient_data].present?
        recipient_data_list = params[:event][:recipient_data].reject(&:blank?)
        recipient_data_list.each do |data_json|
          begin
            data = JSON.parse(data_json)
            @event.recipients.create!(
              first_name: data['first_name'],
              last_name: data['last_name']
            )
          rescue JSON::ParserError
          end
        end
      end
      
      redirect_to events_path, notice: 'Event was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to events_path, notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Event was successfully deleted.'
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_creator!
    unless @event.creator_id == current_user.id
      redirect_to events_path, alert: 'You are not authorized to edit this event'
    end
  end

  def authorize_viewer!
    is_creator = @event.creator_id == current_user.id
    is_attendee = @event.attendees.include?(current_user)
    is_recipient = @event.recipients.exists?(
      first_name: current_user.first_name,
      last_name: current_user.last_name
    )
    
    unless is_creator || is_attendee || is_recipient
      redirect_to events_path, alert: 'You do not have access to this event'
    end
  end

  def event_params
    params.require(:event).permit(:name, :description, :start_at, :end_at, :location, :theme)
  end
end
