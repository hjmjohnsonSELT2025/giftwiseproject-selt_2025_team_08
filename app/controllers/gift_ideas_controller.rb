class GiftIdeasController < ApplicationController
  before_action :require_login
  before_action :set_gift_idea, only: [:show, :update, :add_as_gift]

  def show
    render json: @gift_idea, only: [:id, :idea, :estimated_price, :favorited, :link, :note, :status]
  end

  def update
    if @gift_idea.update(gift_idea_params)
      render json: @gift_idea, only: [:id, :idea, :estimated_price, :favorited, :link, :note, :status]
    else
      render json: @gift_idea.errors, status: :unprocessable_content
    end
  end

  def add_as_gift
    recipient = Recipient.find(params[:recipient_id])
    gift = recipient.gifts_for_recipients.build(
      idea: @gift_idea.idea,
      price: @gift_idea.estimated_price,
      gift_date: Time.zone.today,
      status: 'idea',
      user: current_user
    )
    
    if gift.save
      @gift_idea.update(favorited: false)
      render json: gift, only: [:id, :idea, :price, :gift_date, :status], status: :created
    else
      render json: { errors: gift.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def set_gift_idea
    @gift_idea = GiftIdea.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Gift idea not found' }, status: :not_found
  end

  def gift_idea_params
    params.require(:gift_idea).permit(:idea, :estimated_price, :favorited, :link, :note, :status)
  end
end
