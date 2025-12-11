class GiftForRecipient < ApplicationRecord
  self.table_name = 'gifts_for_recipients'
  
  belongs_to :recipient
  belongs_to :user

  STATUSES = ['idea', 'backlogged', 'purchased', 'delivered', 'wrapped', 'liked'].freeze

  validates :idea, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :gift_date, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: false

  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def deleted?
    deleted_at.present?
  end
end
