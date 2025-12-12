class GiftsForRecipientsController < ApplicationController
  before_action :require_login
  before_action :set_gift, only: [:update, :destroy]

  def create
    @recipient = Recipient.find(params[:recipient_id])
    @gift = @recipient.gifts_for_recipients.build(gift_params)
    @gift.user = current_user
    @gift.status = 'idea' if @gift.status.blank?
    
    if @gift.save
      render json: @gift, only: [:id, :idea, :price, :gift_date, :status]
    else
      render json: { errors: @gift.errors.messages }, status: :unprocessable_content
    end
  end

  def update
    if @gift.update(gift_params)
      render json: @gift, only: [:id, :idea, :price, :gift_date, :status]
    else
      render json: @gift.errors, status: :unprocessable_content
    end
  end

  def destroy
    @gift.soft_delete
    render json: { success: true }
  end

  private

  def set_gift
    @gift = GiftForRecipient.find(params[:id])
  end

  def gift_params
    params.require(:gift_for_recipient).permit(:idea, :price, :gift_date, :status)
  end
end
