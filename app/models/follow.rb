class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", counter_cache: :following_count
  belongs_to :followable, polymorphic: true

  validates :follower_id, uniqueness: { scope: [:followable_type, :followable_id] }
  validate :not_self_follow

  after_create :increment_followers_count
  after_destroy :decrement_followers_count
  after_create :notify_followable

  private

  def not_self_follow
    errors.add(:follower_id, "can't follow yourself") if followable_type == "User" && followable_id == follower_id
  end

  def increment_followers_count
    followable.increment!(:followers_count)
  end

  def decrement_followers_count
    followable.decrement!(:followers_count)
  end

  def notify_followable
    return unless followable_type == "User"

    Notification.create!(
      recipient:  followable,
      actor:      follower,
      notifiable: self,
      action:     :followed
    )
  end
end
