module Api
  class ViewsController < ApiBaseController
    include ActionController::RateLimiting

    skip_before_action :require_authentication

    rate_limit to: 30, within: 1.minute, only: :create, with: -> { head :too_many_requests }

    VIEWABLE_MODELS = { "Article" => Article, "User" => User }.freeze

    # Records one view per visitor. With read: true, marks that visitor's existing view as a read
    # (they stayed and scrolled; see app/javascript/lib/read_tracker.js).
    def create
      model = VIEWABLE_MODELS[params[:viewable_type]]
      visitor_id = params[:visitor_id]
      return head :unprocessable_content unless model && params[:viewable_id].present? && visitor_id.present?

      viewable = model.find_by(id: params[:viewable_id])
      return head :not_found unless viewable

      params[:read].present? ? record_read(viewable, visitor_id) : record_view(viewable, visitor_id)
    end

    private

    # Knowing the signed-in reader lets the ranking ignore authors reading their own articles
    def record_view(viewable, visitor_id)
      resume_session
      view = PageView.find_or_create_by(viewable:, visitor_id:)
      view.update_column(:user_id, Current.user.id) if Current.user && view.user_id.nil?
      head :ok
    end

    def record_read(viewable, visitor_id)
      view = PageView.find_by(viewable:, visitor_id:)
      return head :unprocessable_content unless view

      view.update_column(:read_at, Time.current) if view.read_at.nil?
      head :ok
    end
  end
end
