module BackofficeHelper
  BADGE_COLORS = {
    active:  "bg-primary text-primary-foreground",
    default: "bg-secondary text-secondary-foreground"
  }.freeze

  def status_badge(label, style = :default)
    classes = BADGE_COLORS.fetch(style.to_sym, BADGE_COLORS[:default])
    tag.span label, class: "inline-flex items-center rounded-full px-2 py-0.5 text-[11px] font-medium #{classes}"
  end

  def boolean_badge(value)
    if value
      status_badge("نعم", :active)
    else
      status_badge("لا", :default)
    end
  end

  def active_backoffice_nav(controller)
    if controller_name == controller
      "bg-sidebar-accent text-sidebar-foreground"
    else
      "text-sidebar-muted-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
    end
  end

  def active_backoffice_nav_indicator?(controller)
    controller_name == controller
  end

  def active_filter_tab(current, tab)
    if current.to_s == tab.to_s
      "bg-background text-foreground shadow-sm rounded-md"
    else
      "text-muted-foreground hover:text-foreground rounded-md"
    end
  end
end
