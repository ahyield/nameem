# Write system test for login with magiclink
require "rails_helper"

RSpec.describe "UserLogin" do
  let(:user) { create(:user) }

  context "when user is not logged in" do
    before do
      visit root_path
    end

    it "lets user login with magiclink" do
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

      find_by_id("#user-menu-button").click

      within('[data-controller="dropdown"]') do
        expect(page).to have_link("الصفحة الشخصية", href: user_path(user))
        expect(page).to have_link("اعدادات الحساب", href: settings_user_settings_path)
        expect(page).to have_link("تسجيل خروج", href: logout_path)
      end
    end
  end
end
