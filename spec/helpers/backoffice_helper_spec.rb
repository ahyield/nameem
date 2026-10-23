require "rails_helper"

RSpec.describe BackofficeHelper do
  describe "#status_badge" do
    it "uses the accent style for active badges" do
      expect(helper.status_badge("مميز", :active)).to include("bg-orange-50", "مميز")
    end

    it "falls back to the neutral style" do
      expect(helper.status_badge("مسودة", :unknown)).to include("bg-gray-100")
    end
  end

  describe "#backoffice_avatar" do
    it "shows the first letter of the name when there is no avatar" do
      user = build(:user, first_name: "سارة")
      expect(helper.backoffice_avatar(user, size: 24)).to include("س", "width: 24px")
    end

    it "renders the avatar image when one is attached" do
      user = create(:user, :with_avatar)
      expect(helper.backoffice_avatar(user)).to include("<img")
    end
  end
end
