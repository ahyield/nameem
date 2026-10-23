# Groups a reader's notifications for the daily digest: the same action on the same thing becomes one
# row ("Ahmed, Sara and 3 others liked your article")
class NotificationDigest
  # Nouns, not verbs, so the line reads right for one actor or many
  LABELS = {
    "liked"           => "إعجاب بموضوعك",
    "commented"       => "تعليق على موضوعك",
    "replied"         => "ردّ على تعليقك",
    "comment_liked"   => "إعجاب بتعليقك",
    "followed"        => "متابعة جديدة لك",
    "featured"        => "تمييز موضوعك",
    "picked"          => "اختيار المحررين لموضوعك",
    "report_actioned" => "مراجعة بلاغك واتخاذ إجراء",
    "content_removed" => "إزالة محتوى لك لمخالفته الإرشادات"
  }.freeze

  # Summary chips: singular and plural nouns per kind of activity
  KINDS = {
    "likes"    => { actions: %w[liked comment_liked], one: "إعجاب", many: "إعجابات" },
    "comments" => { actions: %w[commented replied], one: "تعليق", many: "تعليقات" },
    "follows"  => { actions: %w[followed], one: "متابعة", many: "متابعات" }
  }.freeze

  Group = Struct.new(:action, :notifications, :article, :comment, keyword_init: true) do
    def actors = notifications.map(&:actor).uniq
    def label = LABELS.fetch(action)
    def latest = notifications.max_by(&:created_at)
    def moderation? = notifications.first.moderation?
  end

  attr_reader :notifications

  # Notifications whose like, comment or follow was since deleted are left out, as on the notifications page
  def initialize(notifications, helpers)
    @notifications = notifications.select(&:notifiable)
    @helpers = helpers
  end

  # Newest activity first
  def groups
    @groups ||= notifications
                .group_by { |notification| [notification.action, target_key(notification)] }
                .map { |(action, _), grouped| build_group(action, grouped) }
                .sort_by { |group| -group.latest.created_at.to_i }
  end

  # "12 إعجابات · 3 تعليقات · متابعة"
  def summary
    KINDS.values.filter_map do |kind|
      count = notifications.count { |notification| kind[:actions].include?(notification.action) }
      counted(kind, count) unless count.zero?
    end.join(" · ")
  end

  private

  # Arabic counted nouns: one stands alone, 2-10 take the plural, 11+ go back to the singular
  def counted(kind, count)
    case count
    when 1 then kind[:one]
    when 2..10 then "#{count} #{kind[:many]}"
    else "#{count} #{kind[:one]}"
    end
  end

  def build_group(action, grouped)
    first = grouped.first
    Group.new(action:, notifications: grouped, article: @helpers.notification_article(first),
              comment: grouped.one? ? @helpers.notification_comment(first) : nil)
  end

  # Follows group together; everything else groups by the article or comment it's about
  def target_key(notification)
    return :follows if notification.followed?

    @helpers.notification_article(notification)&.id || [notification.notifiable_type, notification.notifiable_id]
  end
end
