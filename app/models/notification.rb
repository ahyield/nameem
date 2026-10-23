class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  enum :action, { liked: 0, commented: 1, featured: 2, picked: 3, followed: 4, replied: 5, comment_liked: 6,
                  report_actioned: 7, content_removed: 8 }

  MODERATION_ACTIONS = %w[report_actioned content_removed].freeze
  # Actions that also get their own email right away, by email category
  INSTANT_EMAIL_CATEGORIES = { "commented" => :comments, "replied" => :comments, "featured" => :editorial,
                               "picked" => :editorial }.freeze
  COMMENT_EMAIL_COOLDOWN = 15.minutes

  after_create_commit :deliver_instant_email, if: -> { INSTANT_EMAIL_CATEGORIES.key?(action) }

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

  private

  # Sends the email now and marks it emailed, so the daily digest doesn't repeat it. Comments on an
  # article the recipient was emailed about in the last 15 minutes wait for the digest instead.
  def deliver_instant_email
    category = INSTANT_EMAIL_CATEGORIES.fetch(action)
    return unless notifiable.is_a?(category == :comments ? Comment : Article)
    return unless recipient.emailable?(category)
    return if category == :comments && recently_emailed_about_article?

    update_column(:emailed_at, Time.current)
    mail = category == :comments ? ActivityMailer.comment(self) : ActivityMailer.editorial(self)
    mail.deliver_later
  end

  def recently_emailed_about_article?
    Notification.where(recipient:, action: %w[commented replied], notifiable_type: "Comment",
                       notifiable_id: Comment.where(article_id: notifiable.article_id).select(:id))
                .where(emailed_at: COMMENT_EMAIL_COOLDOWN.ago..)
                .where.not(id:)
                .exists?
  end
end
