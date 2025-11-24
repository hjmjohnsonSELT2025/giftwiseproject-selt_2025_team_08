class Event < ApplicationRecord
  validates :name, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true

  validate :end_after_start

  private

  def end_after_start
    return if start_at.blank? || end_at.blank?
    errors.add(:end_at, 'must be after start date/time') if end_at < start_at
  end
end
