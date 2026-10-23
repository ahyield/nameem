# Preview at /rails/mailers in development, built from unsaved sample notifications so the grouping shows:
# several likes on one article, a comment, follows and an editors' pick
class NotificationMailerPreview < ActionMailer::Preview
  def digest
    reader = User.first!
    NotificationMailer.digest(reader, sample_notifications(reader))
  end

  private

  def sample_notifications(reader)
    article = Article.published.where(user: reader).first || Article.published.first!
    people = User.where.not(id: reader.id).limit(6).to_a
    likes(reader, article, people.first(5)) + [comment(reader, article, people.last)] +
      follows(reader, people.first(2)) + [notice(reader, User.first!, :picked, article, 5.hours.ago)]
  end

  def likes(reader, article, people)
    people.each_with_index.map do |person, index|
      notice(reader, person, :liked, ArticleLike.new(article:, user: person), (index * 40).minutes.ago)
    end
  end

  def comment(reader, article, person)
    body = "قرأت موضوعك مرتين، والفقرة الأخيرة بقيت معي طوال اليوم."
    notice(reader, person, :commented, Comment.new(article:, user: person, body:), 20.minutes.ago)
  end

  def follows(reader, people)
    people.map { |person| notice(reader, person, :followed, Follow.new(follower: person, followable: reader), 3.hours.ago) }
  end

  def notice(recipient, actor, action, notifiable, created_at)
    Notification.new(recipient:, actor:, action:, notifiable:, created_at:)
  end
end
