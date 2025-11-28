class HomeController < ApplicationController
  before_action :require_login

  def index
    @upcoming_events = Event.upcoming_this_month(current_user)
  end

  def generate_quick_gift_idea
    safe_params = params.permit(:likes, :dislikes, :occupation, :age, :hobbies, :budget)
    
    likes = safe_params[:likes].to_s.strip
    dislikes = safe_params[:dislikes].to_s.strip
    occupation = safe_params[:occupation].to_s.strip
    age = safe_params[:age].to_s.strip
    hobbies = safe_params[:hobbies].to_s.strip
    budget = safe_params[:budget].to_s.strip

    prompt = build_gift_prompt(likes, dislikes, occupation, age, hobbies, budget)
    
    begin
      service = GeminiService.new
      idea = service.generate_multiple_ideas(prompt)
      
      render json: { 
        success: true, 
        idea: idea 
      }, status: :ok
    rescue StandardError => e
      error_message = if e.message.include?("GOOGLE_API_KEY")
        "There was an error trying to generating your gift, please try again."
      else
        "Failed to generate gift idea: #{e.message}"
      end
      
      render json: { 
        success: false, 
        error: error_message
      }, status: :ok
    end
  end

  private

  def build_gift_prompt(likes, dislikes, occupation, age, hobbies, budget)
    prompt_parts = ["Generate one creative and thoughtful gift idea"]
    
    prompt_parts << "for a #{age}-year-old" if age.present?
    prompt_parts << "who works as a #{occupation}" if occupation.present?
    
    prompt = prompt_parts.join(" ") + "."
    
    if likes.present?
      prompt += " They enjoy: #{likes}."
    end
    
    if dislikes.present?
      prompt += " They dislike: #{dislikes}."
    end
    
    if hobbies.present?
      prompt += " Their hobbies include: #{hobbies}."
    end
    
    if budget.present?
      prompt += " Budget: #{budget}."
    end
    
    prompt += " Just list the gift idea, no explanations or reasoning needed. Please keep it short and concise and creative."
    prompt
  end
end
