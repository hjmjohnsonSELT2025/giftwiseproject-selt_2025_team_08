class RecipientsController < ApplicationController
  before_action :require_login
  before_action :set_recipient, only: [:data, :generate_ideas, :gift_ideas, :gifts_for_recipients, :destroy]
  before_action :authorize_recipient_access, only: [:data, :generate_ideas, :gift_ideas, :gifts_for_recipients]
  before_action :set_event, only: [:create]

  def create
    @recipient = @event.recipients.build(recipient_params)
    if @recipient.save
      render json: @recipient, status: :created
    else
      render json: @recipient.errors, status: :unprocessable_content
    end
  end

  def destroy
    begin
      @recipient.destroy
      respond_to do |format|
        format.json { render json: { message: 'Recipient deleted' }, status: :no_content }
        format.html { redirect_to events_path, notice: 'Recipient was successfully deleted.' }
      end
    rescue StandardError => e
      Rails.logger.error("Error destroying recipient: #{e.class} - #{e.message}")
      respond_to do |format|
        format.json { render json: { error: 'Unable to delete recipient' }, status: :unprocessable_entity }
        format.html { redirect_to events_path, alert: 'Unable to delete recipient.' }
      end
    end
  end

  def data
    previous_gifts = @recipient.gifts_for_recipients.where(user_id: current_user.id).limit(5)
    favorited_ideas = @recipient.gift_ideas.where(user_id: current_user.id, favorited: true)
    
    render json: {
      previous_gifts: previous_gifts.as_json(only: [:id, :idea, :price, :gift_date]),
      favorited_ideas: favorited_ideas.as_json(only: [:id, :idea, :estimated_price, :link, :note])
    }
  end

  def generate_ideas
    recipient = @recipient
    
    prompt = build_prompt(recipient)
    num_ideas = sanitize_num_ideas(params[:num_ideas])
    ideas_text = GeminiService.new.generate_multiple_ideas(prompt, num_ideas)
    ideas = parse_ideas(ideas_text)
    
    respond_to do |format|
      format.json { render json: { ideas: ideas }, status: :ok }
    end
  rescue StandardError => e
    Rails.logger.error("Error generating ideas: #{e.class} - #{e.message}")
    respond_to do |format|
      format.json { render json: { error: 'Failed to generate ideas' }, status: :unprocessable_entity }
    end
  end

  def gift_ideas
    @gift_idea = @recipient.gift_ideas.build(gift_idea_params)
    @gift_idea.user = current_user
    
    if @gift_idea.save
      render json: @gift_idea, status: :created
    else
      render json: @gift_idea.errors, status: :unprocessable_content
    end
  end

  def gifts_for_recipients
    @gift = @recipient.gifts_for_recipients.build(gift_params)
    @gift.user = current_user
    
    if @gift.save
      render json: @gift, status: :created
    else
      render json: @gift.errors, status: :unprocessable_content
    end
  end

  private

  def set_recipient
    @recipient = Recipient.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def authorize_recipient_access
    @recipient = Recipient.find(params[:id])
    event = @recipient.event
    
    is_creator = event.creator_id == current_user.id
    is_attendee = event.attendees.include?(current_user)
    is_recipient = event.recipients.exists?(
      first_name: current_user.first_name,
      last_name: current_user.last_name
    )
    
    return if is_creator || is_attendee || is_recipient
    
    Rails.logger.warn("Unauthorized recipient access: user=#{current_user.id}, recipient=#{@recipient.id}, event=#{event.id}")
    
    if request.format.json?
      render json: { error: 'Unauthorized' }, status: :forbidden
    else
      redirect_to events_path, alert: 'You do not have access to this recipient.'
    end
  end

  def sanitize_num_ideas(param)
    num = param.to_i
    [[num, 1].max, 10].min
  end

  def recipient_params
    params.require(:recipient).permit(:first_name, :last_name, :age, :occupation, :hobbies, :likes, :dislikes)
  end

  def gift_idea_params
    params.require(:gift_idea).permit(:idea, :estimated_price, :favorited, :link, :note)
  end

  def gift_params
    params.require(:gift_for_recipient).permit(:idea, :price, :gift_date)
  end

  def build_prompt(recipient)
    price_min = params[:price_min].to_f.round(2) if params[:price_min].present?
    price_max = params[:price_max].to_f.round(2) if params[:price_max].present?
    num_ideas = sanitize_num_ideas(params[:num_ideas])
    
    prompt = "You are a helpful gift suggestion assistant. Generate thoughtful gift ideas for the following person:\n\n"
    prompt += "Name: #{sanitize_for_prompt(recipient.first_name)} #{sanitize_for_prompt(recipient.last_name)}\n"
    prompt += "Age: #{recipient.age}\n" if recipient.age.present?
    prompt += "Occupation: #{sanitize_for_prompt(recipient.occupation)}\n" if recipient.occupation.present?
    prompt += "Hobbies: #{sanitize_for_prompt(recipient.hobbies)}\n" if recipient.hobbies.present?
    prompt += "Likes: #{sanitize_for_prompt(recipient.likes)}\n" if recipient.likes.present?
    prompt += "Dislikes: #{sanitize_for_prompt(recipient.dislikes)}\n" if recipient.dislikes.present?
    prompt += "Price Range: $#{price_min} - $#{price_max}\n" if price_min.present? || price_max.present?
    prompt += "\nGenerate #{num_ideas} unique and thoughtful gift ideas. Return each idea as a separate numbered item."
    
    prompt
  end

  def sanitize_for_prompt(text)
    return nil if text.blank?
    text.to_s.strip.gsub(/[\r\n;"'\\]/, '').truncate(200, omission: '')
  end

  def parse_ideas(text)
    ideas = text.split("\n").map { |line| line.strip }.select { |line| line =~ /^\d+\./ }
    ideas.map { |idea| idea.gsub(/^\d+\.\s*/, '').strip }
  end
end
