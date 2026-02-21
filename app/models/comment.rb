class Comment < ApplicationRecord
  belongs_to :article, counter_cache: :comments_count
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count
  belongs_to :mentioned_user, class_name: "User", optional: true

  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :comment_likes, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  has_rich_text :body

  validates :body, presence: true

  scope :top_level, -> { where(parent_id: nil) }

  after_create :notify_author

  private

  def notify_author
    if parent_id.nil?
      # Top-level comment: notify article author
      return if user == article.user

      Notification.create!(
        recipient:  article.user,
        actor:      user,
        notifiable: self,
        action:     :commented
      )
    elsif mentioned_user.present?
      # Reply-to-reply (collapsed): notify mentioned user
      return if user == mentioned_user

      Notification.create!(
        recipient:  mentioned_user,
        actor:      user,
        notifiable: self,
        action:     :replied
      )
    else
      # Direct reply to top-level: notify parent comment author
      return if user == parent.user

      Notification.create!(
        recipient:  parent.user,
        actor:      user,
        notifiable: self,
        action:     :replied
      )
    end
  end
end
