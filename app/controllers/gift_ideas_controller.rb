class GiftIdeasController < ApplicationController
  before_action :require_login
  before_action :set_gift_idea, only: [:show, :update]

  def show
    render json: @gift_idea, only: [:id, :idea, :estimated_price, :favorited]
  end

  def update
    if @gift_idea.update(gift_idea_params)
      render json: @gift_idea, only: [:id, :idea, :estimated_price, :favorited]
    else
      render json: @gift_idea.errors, status: :unprocessable_content
    end
  end

  private

  def set_gift_idea
    @gift_idea = GiftIdea.find(params[:id])
  end

  def gift_idea_params
    params.require(:gift_idea).permit(:idea, :estimated_price, :favorited)
  end
end
