module Email
  # Unsubscribe links in emails work without signing in; the signed token names the user and category
  class UnsubscribesController < ApplicationController
    skip_before_action :require_authentication
    # Mail clients POST here for one-click unsubscribe (RFC 8058), without a form token
    skip_forgery_protection only: :create
    before_action :set_subscription

    def show; end

    def create
      @user.unsubscribe_from!(@category)
      render :done
    end

    private

    def set_subscription
      @user, @category = User.from_unsubscribe_token(params[:token].to_s)
      render_not_found unless @user
    end
  end
end
