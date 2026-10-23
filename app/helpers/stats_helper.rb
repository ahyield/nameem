module StatsHelper
  SORT_ARROWS = { desc: "↓", asc: "↑" }.freeze
  ARIA_SORT   = { desc: "descending", asc: "ascending" }.freeze

  # Column header that sorts the stats table; clicking the active column flips the direction
  def stats_sort_header(label, key)
    current = @sort == key ? @direction : nil
    next_direction = current == :desc ? "asc" : "desc"

    tag.th scope: "col", class: "px-6 py-3.5 text-right text-xs font-semibold text-gray-500", aria: { sort: ARIA_SORT[current] } do
      link_to user_stats_path(@user, sort: key, direction: next_direction, anchor: "articles"),
              class: "inline-flex items-center gap-1 hover:text-gray-900 #{"text-gray-900" if current}" do
        safe_join([label, tag.span(SORT_ARROWS.fetch(current, ""), class: "inline-block w-2 text-orange-600", aria: { hidden: true })])
      end
    end
  end
end
