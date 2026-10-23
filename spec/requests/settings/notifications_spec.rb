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

  it "saves each email category separately" do
    put settings_update_notifications_path,
        params: { user: { email_notifications: "1", email_comments: "0", email_editorial: "1", email_weekly: "0" } }

    expect(user.reload).to have_attributes(email_notifications: true, email_comments: false, email_editorial: true,
                                           email_weekly: false)
  end

  it "lists every category and explains a suppressed address" do
    user.suppress_email!("bounce")
    get settings_notifications_path

    Email::Categories::OPTIONAL.each { |category| expect(response.body).to include(Email::Categories::ALL[category][:label]) }
    expect(response.body).to include("توقّفنا عن مراسلة هذا العنوان")
  end
end
