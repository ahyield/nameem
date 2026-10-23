require "rails_helper"

RSpec.describe "Email unsubscribe" do
  let(:user) { create(:user) }
  let(:token) { user.unsubscribe_token(:weekly) }

  it "asks before unsubscribing, without signing in" do
    get email_unsubscribe_path(token:)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("الأفضل هذا الأسبوع")
    expect(user.reload.email_weekly).to be(true)
  end

  it "unsubscribes from just that category" do
    post email_unsubscribe_path, params: { token: }

    expect(response.body).to include("تم إلغاء الاشتراك")
    expect(user.reload.email_weekly).to be(false)
    expect(user.email_comments).to be(true)
  end

  it "accepts the one-click POST that mail clients send" do
    post email_unsubscribe_path(token:), params:  "List-Unsubscribe=One-Click",
                                         headers: { "CONTENT_TYPE" => "application/x-www-form-urlencoded" }

    expect(response).to have_http_status(:ok)
    expect(user.reload.email_weekly).to be(false)
  end

  it "rejects a tampered token" do
    get email_unsubscribe_path(token: "#{token}x")
    expect(response).to have_http_status(:not_found)

    post email_unsubscribe_path, params: { token: "nonsense" }
    expect(response).to have_http_status(:not_found)
  end
end
