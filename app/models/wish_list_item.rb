class WishListItem < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :description, length: { maximum: 1000 }, allow_nil: true, allow_blank: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w(http https)), message: "must be a valid URL" }, allow_nil: true, allow_blank: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :user_id, uniqueness: { scope: :name, message: "can only have one item with this name" }

  validate :user_cannot_have_more_than_10_items, on: :create

  private

  def user_cannot_have_more_than_10_items
    if user && user.wish_list_items.count >= 10
      errors.add(:base, "You can only have up to 10 items in your wish list")
    end
  end
end
