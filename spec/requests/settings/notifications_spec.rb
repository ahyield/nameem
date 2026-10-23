require "rails_helper"

RSpec.describe "Settings: notifications" do
  let(:user) { create(:user, email_notifications: true) }

  before { authenticate_user(user) }

  it "shows the settings page" do
    get settings_notifications_path
    expect(response).to have_http_status(:ok)
  end

  it "turns email notifications off" do
    put settings_update_notifications_path, params: { user: { email_notifications: false } }

    expect(response).to redirect_to(settings_notifications_path)
    expect(user.reload.email_notifications).to be(false)
  end

  it "ignores attributes other than the notification preference" do
    put settings_update_notifications_path, params: { user: { email_notifications: false, admin: true } }

    expect(user.reload.admin).to be(false)
  end
end
