module BackofficeHelper
  BADGE_COLORS = {
    active:  "bg-indigo-600 text-white",
    default: "bg-gray-100 text-gray-900"
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
      "border-r-[3px] border-indigo-600 text-gray-950 font-bold"
    else
      "text-gray-400 hover:text-gray-950 font-medium"
    end
  end

  def active_backoffice_nav_indicator?(controller)
    controller_name == controller
  end

  def active_filter_tab(current, tab)
    if current.to_s == tab.to_s
      "bg-white text-gray-950 shadow-sm rounded-md"
    else
      "text-gray-500 hover:text-gray-950 rounded-md"
    end
  end
end
