class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  enum :action, { liked: 0, commented: 1, featured: 2, picked: 3, followed: 4, replied: 5, comment_liked: 6,
                  report_actioned: 7, content_removed: 8 }

  MODERATION_ACTIONS = %w[report_actioned content_removed].freeze

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Sent by the moderation team rather than another reader
  def moderation?
    MODERATION_ACTIONS.include?(action)
  end

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end
end
