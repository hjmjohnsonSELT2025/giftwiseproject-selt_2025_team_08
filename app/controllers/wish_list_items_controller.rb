class WishListItemsController < ApplicationController
  before_action :require_login
  before_action :set_wish_list_item, only: [:edit, :update, :destroy]

  def index
    @wish_list_items = current_user.wish_list_items.order(created_at: :desc)
  end

  def new
    @wish_list_item = current_user.wish_list_items.build
  end

  def create
    @wish_list_item = current_user.wish_list_items.build(wish_list_item_params)

    if @wish_list_item.save
      redirect_to wish_list_items_path, notice: 'Wish list item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @wish_list_item.update(wish_list_item_params)
      redirect_to wish_list_items_path, notice: 'Wish list item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wish_list_item.destroy
    redirect_to wish_list_items_path, notice: 'Wish list item was successfully destroyed.'
  end

  private

  def set_wish_list_item
    @wish_list_item = current_user.wish_list_items.find(params[:id])
  end

  def wish_list_item_params
    params.require(:wish_list_item).permit(:name, :description, :url, :price)
  end
end
