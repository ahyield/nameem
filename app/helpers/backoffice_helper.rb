module BackofficeHelper
  BADGE_COLORS = {
    active:  "bg-orange-50 text-orange-700",
    default: "bg-gray-100 text-gray-600"
  }.freeze

  NAV_ITEMS = [
    ["dashboard", :backoffice_dashboard_path, "الرئيسية"],
    ["articles", :backoffice_articles_path, "المقالات"],
    ["users", :backoffice_users_path, "المستخدمين"],
    ["tags", :backoffice_tags_path, "المواضيع"],
    ["comments", :backoffice_comments_path, "التعليقات"],
    ["reports", :backoffice_reports_path, "البلاغات"]
  ].freeze

  def pending_reports_count
    @pending_reports_count ||= Report.pending.count
  end

  def status_badge(label, style = :default)
    classes = BADGE_COLORS.fetch(style.to_sym, BADGE_COLORS[:default])
    tag.span label, class: "inline-flex items-center rounded-md px-1.5 py-0.5 text-xs font-medium #{classes}"
  end

  def active_backoffice_nav(controller)
    if controller_name == controller
      "text-gray-900 after:absolute after:inset-x-0 after:-bottom-px after:h-0.5 after:bg-orange-600"
    else
      "text-gray-500 hover:text-gray-900"
    end
  end

  def active_filter_tab(current, tab)
    if current.to_s == tab.to_s
      "bg-surface text-gray-900 shadow-sm"
    else
      "text-gray-500 hover:text-gray-900"
    end
  end

  def backoffice_avatar(user, size: 32)
    classes = "rounded-full shrink-0"
    style = "width: #{size}px; height: #{size}px"

    if user.avatar.attached?
      image_tag user.avatar.variant(resize_to_fill: [size * 2, size * 2]), class: classes, style: style, alt: ""
    else
      tag.span user.name.to_s.first,
               class: "#{classes} inline-flex items-center justify-center bg-orange-50 font-medium text-orange-700",
               style: "#{style}; font-size: #{(size * 0.4).round}px"
    end
  end
end
