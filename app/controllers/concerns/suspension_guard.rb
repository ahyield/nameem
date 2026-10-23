# Blocks suspended users from actions that publish or interact. Use it on actions that require
# signing in, e.g.  before_action :refuse_suspended_user, only: :create
module SuspensionGuard
  extend ActiveSupport::Concern

  SUSPENDED_MESSAGE = "حسابك موقوف حالياً".freeze

  private

  def refuse_suspended_user
    return unless Current.user.suspended?

    # Turbo Stream requests also count as html?, so compare with plain HTML
    if request.format == Mime[:html]
      redirect_back_or_to root_path, alert: SUSPENDED_MESSAGE
    else
      head :forbidden
    end
  end
end
