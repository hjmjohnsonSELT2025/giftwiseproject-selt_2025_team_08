class Discussion < ApplicationRecord
  THREAD_TYPES = %w(public contributors_only).freeze

  belongs_to :event
  has_many :messages, class_name: 'DiscussionMessage', dependent: :destroy

  validates :event_id, presence: true
  validates :thread_type, presence: true, inclusion: { in: THREAD_TYPES }
  validates :event_id, uniqueness: { scope: :thread_type }

  scope :public_thread, -> { where(thread_type: 'public') }
  scope :contributors_only_thread, -> { where(thread_type: 'contributors_only') }
end
