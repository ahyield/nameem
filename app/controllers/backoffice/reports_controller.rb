module Backoffice
  class ReportsController < BaseController
    before_action :set_report, only: %i[show resolve]

    def index
      @page_title = "البلاغات"
      @filter = params[:filter] || "pending"

      reports = filter_reports(Report.all)
      reports = search_reports(reports) if params[:q].present?

      # One row per reported item, most reported first
      items = reports.group(:reportable_type, :reportable_id)
                     .select("MIN(reports.id) AS id, reports.reportable_type, reports.reportable_id, " \
                             "COUNT(*) AS reports_count, MIN(reports.created_at) AS first_reported_at")
                     .order(Arel.sql("COUNT(*) DESC, MIN(reports.created_at) ASC"))
      @pagy, @items = pagy(items)
      load_item_details(reports)
    end

    def show
      @page_title = "بلاغ عن #{@report.reportable_type == 'Comment' ? 'تعليق' : 'موضوع'}"
      @reports = Report.for_item(@report).includes(:reporter, :reviewer).order(:created_at)
      @pending = @reports.select(&:pending?)
      @author = @report.reported_user
      @author_actioned_count = actioned_items_by(@author)
    end

    def resolve
      resolution = Report::Resolution.new(
        @report,
        reviewer:         current_user,
        decision:         params[:decision],
        note:             params[:note],
        remove_content:   params[:remove_content] == "1",
        warn_author:      params[:warn_author] == "1",
        notify_reporters: params[:notify_reporters] == "1",
        suspend_author:   params[:suspend_author] == "1"
      )

      if resolution.valid?
        flash[:notice] = resolution.call.any? ? "تمت مراجعة البلاغ" : "تمت مراجعة هذا البلاغ مسبقاً"
        redirect_to backoffice_reports_path
      else
        flash[:error] = "اختر قراراً"
        redirect_to backoffice_report_path(@report)
      end
    end

    private

    def set_report
      @report = Report.find(params[:id])
    end

    # How many of the author's items were found to break the rules
    def actioned_items_by(author)
      return 0 unless author

      Report.actioned.where(reported_user: author).group(:reportable_type, :reportable_id).count.size
    end

    def filter_reports(reports)
      case @filter
      when "comments" then reports.pending.where(reportable_type: "Comment")
      when "articles" then reports.pending.where(reportable_type: "Article")
      when "resolved" then reports.resolved
      when "all"      then reports
      else reports.pending
      end
    end

    def search_reports(reports)
      q = "%#{params[:q]}%"
      reports.left_joins(:reported_user)
             .where("reports.snapshot LIKE :q OR users.first_name LIKE :q OR users.last_name LIKE :q", q: q)
    end

    # The snapshot, author and reasons for each row on the current page
    def load_item_details(reports)
      keys = @items.map { |item| [item.reportable_type, item.reportable_id] }
      @samples = Report.includes(:reported_user).where(id: @items.map(&:id)).index_by(&:id)
      @reasons = Hash.new { |hash, key| hash[key] = [] }
      reports.where(reportable_type: keys.map(&:first), reportable_id: keys.map(&:last))
             .pluck(:reportable_type, :reportable_id, :reason)
             .each { |type, id, reason| @reasons[[type, id]] << reason }
    end
  end
end
