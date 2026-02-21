class CommentLike < ApplicationRecord
  belongs_to :comment, counter_cache: :likes_count
  belongs_to :user

  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :user_id, uniqueness: { scope: :comment_id }

  after_create :notify_author

  private

  def notify_author
    return if user == comment.user

    Notification.create!(
      recipient:  comment.user,
      actor:      user,
      notifiable: self,
      action:     :comment_liked
    )
  end
end
