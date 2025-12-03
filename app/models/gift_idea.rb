class GiftIdea < ApplicationRecord
  belongs_to :recipient
  belongs_to :user

  validates :idea, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :estimated_price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :favorited, inclusion: { in: [true, false] }, allow_nil: true
  validates :link, format: { with: URI::DEFAULT_PARSER.make_regexp(%w(http https)), message: "must be a valid URL" }, allow_nil: true, allow_blank: true
  validates :note, length: { maximum: 255 }, allow_nil: true, allow_blank: true
end
