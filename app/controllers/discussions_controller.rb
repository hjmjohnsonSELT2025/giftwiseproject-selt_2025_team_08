class DiscussionsController < ApplicationController
  before_action :require_login
  before_action :set_event
  before_action :authorize_access

  def show
    @thread_type = params[:thread_type] || Discussion::THREAD_TYPES.first
    validate_thread_type!(@thread_type)
    @discussion = @event.discussions.send("#{@thread_type}_thread").first_or_create!
    @messages = @discussion.messages.eager_load(:user).ordered.last(50)
    @new_message = DiscussionMessage.new
  end

  def messages_feed
    @thread_type = params[:thread_type] || Discussion::THREAD_TYPES.first
    validate_thread_type!(@thread_type)
    @discussion = @event.discussions.send("#{@thread_type}_thread").first_or_create!
    
    if params[:after_message_id]
      after_id = params[:after_message_id].to_i
      @messages = @discussion.messages.where('discussion_messages.id > ?', after_id).eager_load(:user).ordered
    else
      @messages = []
    end
    
    render json: { messages: @messages.map { |m| format_message(m, current_user) } }
  end

  def create_message
    @thread_type = params[:thread_type] || Discussion::THREAD_TYPES.first
    validate_thread_type!(@thread_type)
    @discussion = @event.discussions.send("#{@thread_type}_thread").first_or_create!
    @new_message = @discussion.messages.build(discussion_message_params)
    @new_message.user = current_user

    if @new_message.save
      respond_to do |format|
        format.json { render json: { success: true, message_id: @new_message.id } }
        format.html { redirect_to event_discussions_path(@event, thread_type: @thread_type) }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @new_message.errors.full_messages }, status: :unprocessable_entity }
        format.html do
          @messages = @discussion.messages.ordered
          render :show, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def authorize_access
    is_creator = @event.creator_id == current_user.id
    is_attendee = @event.attendees.include?(current_user)
    is_recipient = @event.recipients.exists?(
      first_name: current_user.first_name,
      last_name: current_user.last_name
    )

    thread_type = params[:thread_type] || 'public'
    validate_thread_type!(thread_type)

    if thread_type == Discussion::THREAD_TYPES.first
      unless is_creator || is_attendee || is_recipient
        handle_unauthorized_access('You do not have access to this discussion.')
      end
      return
    end

    unless is_creator || is_attendee
      handle_unauthorized_access('You do not have access to the contributors discussion.')
    end
  end

  def validate_thread_type!(thread_type)
    unless Discussion::THREAD_TYPES.include?(thread_type)
      Rails.logger.warn("Invalid thread type: #{thread_type} by user #{current_user.id}")
      if request.format.json?
        render json: { error: 'Invalid thread type' }, status: :bad_request
      else
        handle_unauthorized_access('Invalid discussion thread type.')
      end
    end
  end

  def handle_unauthorized_access(message)
    Rails.logger.warn("Unauthorized discussion access: user=#{current_user.id}, event=#{@event.id}, thread_type=#{params[:thread_type]}")
    if request.format.json?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    else
      redirect_to event_path(@event), alert: message
    end
  end

  def discussion_message_params
    params.require(:discussion_message).permit(:content)
  end

  def format_message(message, current_user)
    {
      id: message.id,
      content: message.content,
      user_name: "#{message.user.first_name} #{message.user.last_name}",
      is_own: message.user_id == current_user.id,
      timestamp: message.created_at.to_i
    }
  end
end
