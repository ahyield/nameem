class NotificationsController < ApplicationController
  def index
    @pagy, @notifications = pagy(
      current_user.notifications.recent.includes(:actor, :notifiable),
      items: 20
    )
    @unread_count = current_user.notifications.unread.count

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notifications_path }
    end
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path
  end
end
