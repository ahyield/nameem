# Write system test for login with magiclink
require "rails_helper"

RSpec.describe "UserLogin" do
  let(:user) { build(:user) }

  context "when user is not logged in" do
    before do
      visit root_path
      allow_instance_of(ApplicationController).to receive(:valid_captcha?).and_return(true)
    end

    it "lets user login with magiclink" do
      click_button "حساب جديد"

      fill_in :email, with: user.email, match: :first

      perform_enqueued_jobs do
        click_button "تسجيل"
      end

      expect(page).to have_content("من فضلك راجع بريدك الإليكتروني")

      # Check if email is sent
      expect(ActionMailer::Base.deliveries.count).to eq(1)

      # Open email
      open_email(user.email)

      current_email.click_link "تأكيد البريد الإليكتروني"

      expect(page).to have_text("إسمك بالعربية")

      fill_in :name, with: user.name, match: :first

      click_button "تسجيل"

      sleep 2
      # Get the user from the database
      confirmed_user = User.find_by(email: user.email)

      find_by_id("user-menu-button").click

      sleep 2

      within('[data-controller="dropdown"]') do
        expect(page).to have_link("الصفحة الشخصية", href: user_path(confirmed_user))
        expect(page).to have_link("اعدادات الحساب", href: settings_user_settings_path)
        expect(page).to have_link("تسجيل خروج", href: logout_path)
      end
    end
  end
end
