class GiftsForRecipientsController < ApplicationController
  before_action :require_login
  before_action :set_gift, only: [:update]

  def update
    if @gift.update(gift_params)
      render json: @gift, only: [:id, :idea, :price, :gift_date, :status]
    else
      render json: @gift.errors, status: :unprocessable_content
    end
  end

  private

  def set_gift
    @gift = GiftForRecipient.find(params[:id])
  end

  def gift_params
    params.require(:gift_for_recipient).permit(:idea, :price, :gift_date, :status)
  end
end
