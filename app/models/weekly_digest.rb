# What goes into the Friday "best of the week" email; built once per send and shared by every recipient
class WeeklyDigest
  MINIMUM_ARTICLES = 3

  def self.current
    new(Time.current)
  end

  def initialize(now)
    @since = now - 7.days
  end

  def trending
    @trending ||= Article.trending.includes(:user, images_attachments: :blob).limit(5).to_a
  end

  # This week's editors' picks that aren't already in the trending list
  def picks
    @picks ||= Article.published.picked.where(published_at: @since..).where.not(id: trending.map(&:id))
                      .includes(:user).order(published_at: :desc).limit(3).to_a
  end

  def worth_sending?
    Article.published.where(published_at: @since..).count >= MINIMUM_ARTICLES
  end

  def audience
    User.confirmed.where(email_weekly: true, email_suppressed_at: nil)
  end
end
