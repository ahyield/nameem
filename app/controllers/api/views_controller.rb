module Api
  class ViewsController < ApiBaseController
    include ActionController::RateLimiting

    skip_before_action :require_authentication

    rate_limit to: 30, within: 1.minute, only: :create, with: -> { head :too_many_requests }

    ALLOWED_TYPES = %w[Article User].freeze

    def create
      viewable_type = params[:viewable_type]
      viewable_id = params[:viewable_id]
      visitor_id = params[:visitor_id]

      unless ALLOWED_TYPES.include?(viewable_type) && viewable_id.present? && visitor_id.present?
        return head :unprocessable_entity
      end

      viewable = viewable_type.constantize.find_by(id: viewable_id)
      return head :not_found unless viewable

      PageView.find_or_create_by(viewable: viewable, visitor_id: visitor_id)

      head :ok
    end
  end
end
