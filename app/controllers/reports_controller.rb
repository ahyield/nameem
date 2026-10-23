class ReportsController < ApplicationController
  rate_limit to: 10, within: 1.hour, by: -> { current_user.id }, with: -> { head :too_many_requests }

  def create
    reportable = find_reportable
    return head :not_found unless reportable
    return head :forbidden if reportable.user_id == current_user.id

    @report = current_user.reports_filed.find_or_initialize_by(reportable:)
    if @report.persisted? || @report.update(report_params)
      respond_to do |format|
        format.turbo_stream
      end
    else
      head :unprocessable_content
    end
  end

  private

  # Only published articles and comments on them can be reported; the type comes from an allowlist
  def find_reportable
    case params[:reportable_type]
    when "Article" then Article.published.find_by(uuid: params[:reportable_id])
    when "Comment" then Comment.joins(:article).merge(Article.published).find_by(id: params[:reportable_id])
    end
  end

  def report_params
    params.expect(report: %i[reason details])
  end
end
