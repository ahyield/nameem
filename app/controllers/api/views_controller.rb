module Api
  class ViewsController < ApiBaseController
    include ActionController::RateLimiting

    skip_before_action :require_authentication

    rate_limit to: 30, within: 1.minute, only: :create, with: -> { head :too_many_requests }

    VIEWABLE_MODELS = { "Article" => Article, "User" => User }.freeze

    def create
      viewable_type = params[:viewable_type]
      viewable_id = params[:viewable_id]
      visitor_id = params[:visitor_id]

      model = VIEWABLE_MODELS[viewable_type]
      return head :unprocessable_content unless model && viewable_id.present? && visitor_id.present?

      viewable = model.find_by(id: viewable_id)
      return head :not_found unless viewable

      PageView.find_or_create_by(viewable: viewable, visitor_id: visitor_id)

      head :ok
    end
  end
end
