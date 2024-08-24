# Write system test for login with magiclink
require "rails_helper"

RSpec.describe "UserLogin" do
  let(:user) { create(:user, email: "n@n.com") }

  before do
    driven_by(:rack_test)
  end

  it "user login with magiclink" do
    visit root_path

    within(".menu") do
      click_link "دخول"
    end

    fill_in :email, with: user.email, match: :first
    perform_enqueued_jobs do
      click_button "تسجيل دخول"
    end

    expect(page).to have_content("من فضلك تحقق من بريدك الإليكتروني.")

    # Check if email is sent
    expect(ActionMailer::Base.deliveries.count).to eq(1)

    # Open email
    open_email(user.email)

    current_email.click_link "تسجيل الدخول"

    # Login
    expect(page).to have_content(user.name)
  end
end
