require "rails_helper"

RSpec.describe CleanupStaleMagicLinksJob do
  describe "#perform" do
    it "deletes expired magic links" do
      create(:magic_link, :expired)
      create(:magic_link, :expired)

      expect { described_class.perform_now }.to change(MagicLink, :count).by(-2)
    end

    it "does not delete active magic links" do
      active_link = create(:magic_link)
      create(:magic_link, :expired)

      described_class.perform_now

      expect(MagicLink.find_by(id: active_link.id)).to be_present
    end
  end
end
