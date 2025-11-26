class RecipientsController < ApplicationController
  before_action :require_login
  before_action :set_recipient, only: [:data, :generate_ideas, :gift_ideas, :gifts_for_recipients, :destroy]
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
      render json: { message: 'Recipient deleted' }, status: :ok
    rescue => e
      puts "ERROR destroying recipient: #{e.message}"
      puts e.backtrace.join("\n")
      render json: { error: e.message }, status: :unprocessable_content
    end
  end

  def data
    previous_gifts = @recipient.gifts_for_recipients.where(user_id: current_user.id).limit(5)
    favorited_ideas = @recipient.gift_ideas.where(user_id: current_user.id, favorited: true)
    
    render json: {
      previous_gifts: previous_gifts.as_json(only: [:id, :idea, :price, :gift_date]),
      favorited_ideas: favorited_ideas.as_json(only: [:id, :idea, :estimated_price])
    }
  end

  def generate_ideas
    recipient = @recipient
    
    # Build prompt with recipient information
    prompt = build_prompt(recipient)
    
    # Call Gemini API
    num_ideas = params[:num_ideas].to_i || 3
    ideas_text = GeminiService.new.generate_multiple_ideas(prompt, num_ideas)
    ideas = parse_ideas(ideas_text)
    
    render json: { ideas: ideas }
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

  def recipient_params
    params.require(:recipient).permit(:first_name, :last_name, :age, :occupation, :hobbies, :likes, :dislikes)
  end

  def gift_idea_params
    params.require(:gift_idea).permit(:idea, :estimated_price, :favorited)
  end

  def gift_params
    params.require(:gift_for_recipient).permit(:idea, :price, :gift_date)
  end

  def build_prompt(recipient)
    prompt = "You are a helpful gift suggestion assistant. Generate thoughtful gift ideas for the following person:\n\n"
    prompt += "Name: #{recipient.first_name} #{recipient.last_name}\n"
    prompt += "Age: #{recipient.age}\n" if recipient.age.present?
    prompt += "Occupation: #{recipient.occupation}\n" if recipient.occupation.present?
    prompt += "Hobbies: #{recipient.hobbies}\n" if recipient.hobbies.present?
    prompt += "Likes: #{recipient.likes}\n" if recipient.likes.present?
    prompt += "Dislikes: #{recipient.dislikes}\n" if recipient.dislikes.present?
    prompt += "Price Range: $#{params[:price_min]} - $#{params[:price_max]}\n" if params[:price_min].present? || params[:price_max].present?
    prompt += "\nGenerate #{params[:num_ideas] || 3} unique and thoughtful gift ideas. Return each idea as a separate numbered item."
    
    prompt
  end

  def parse_ideas(text)
    ideas = text.split("\n").map { |line| line.strip }.select { |line| line =~ /^\d+\./ }
    ideas.map { |idea| idea.gsub(/^\d+\.\s*/, '').strip }
  end
end
