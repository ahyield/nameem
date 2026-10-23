module EmailHelper
  # An absolute URL to the article's first image, cropped on the server: email clients (Gmail included)
  # ignore object-fit, so CSS can't crop it. size is [width, height] in pixels, at 2x for sharp screens.
  def email_cover_url(article, size)
    image = article.images.first
    return unless image&.variable?

    rails_representation_url(image.variant(resize_to_fill: size))
  end

  # "أحمد", "أحمد وسارة", "أحمد وسارة وآخر", "أحمد وسارة وآخران", "أحمد وسارة و5 آخرين", "أحمد وسارة و12 آخر"
  def email_actor_names(group)
    names = group.moderation? ? [NotificationsHelper::MODERATION_SENDER] : group.actors.map(&:name)
    shown = names.first(2)
    others = names.size - shown.size
    rest = case others
           when 0 then nil
           when 1 then "آخر"
           when 2 then "آخران"
           when 3..10 then "#{others} آخرين"
           else "#{others} آخر"
           end
    [shown.join(" و"), rest].compact.join(" و")
  end

  # "17 – 24 أكتوبر"
  def email_week_range(now = Time.current)
    start = now.to_date - 7
    finish = now.to_date
    if start.month == finish.month
      "#{start.day} – #{l(finish, format: '%-d %B', locale: :ar)}"
    else
      "#{l(start, format: '%-d %B', locale: :ar)} – #{l(finish, format: '%-d %B', locale: :ar)}"
    end
  end
end
