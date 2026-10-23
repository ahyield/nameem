require "rails_helper"

RSpec.describe "Settings: profile links" do
  let(:user) { create(:user) }

  before { authenticate_user(user) }

  def update_profile(attributes)
    put settings_update_profile_path, params: { user: attributes }
  end

  it "rejects a javascript: website URL" do
    update_profile(website_url: "javascript:alert(document.cookie)")

    expect(response).to have_http_status(:unprocessable_entity)
    expect(user.reload.website_url).to be_nil
  end

  it "saves a website and shows it on the profile" do
    update_profile(website_url: "nameem.com", twitter_handle: "@nameem")

    expect(user.reload.website_url).to eq("https://nameem.com")
    get user_path(user)
    expect(response.body).to include('href="https://nameem.com"', 'href="https://x.com/nameem"')
  end

  it "never renders an unsafe website saved before validation existed" do
    user.update_column(:website_url, "javascript:alert(1)")

    get user_path(user)
    expect(response.body).not_to include("javascript:alert")
  end
end
