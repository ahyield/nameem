class Comment < ApplicationRecord
  belongs_to :article, counter_cache: :comments_count
  belongs_to :user

  has_rich_text :body

  validates :body, presence: true

  after_create :notify_author

  private

  def notify_author
    return if user == article.user

    Notification.create!(
      recipient:  article.user,
      actor:      user,
      notifiable: self,
      action:     :commented
    )
  end
end
