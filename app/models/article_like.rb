class ArticleLike < ApplicationRecord
  belongs_to :article, counter_cache: :likes_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :article_id }

  after_create :notify_author

  private

  def notify_author
    return if user == article.user

    Notification.create!(
      recipient:  article.user,
      actor:      user,
      notifiable: self,
      action:     :liked
    )
  end
end
