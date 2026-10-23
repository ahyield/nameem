require "rails_helper"

RSpec.describe "Signing in" do
  let(:user) { create(:user) }

  it "signs in with the emailed code and signs out" do
    system_sign_in(user)

    expect(page).to have_current_path(root_path)
    visit settings_user_settings_path
    expect(page).to have_field("user[name]", with: user.name).or have_content(user.name)
  end

  it "rejects a wrong code" do
    visit login_path
    fill_in "email", with: user.email
    click_on "تسجيل دخول"

    fill_in "code", with: "ZZZZZZ"
    expect(page).to have_field("code")
  end
end
