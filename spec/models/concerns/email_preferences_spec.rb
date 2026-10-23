require "rails_helper"

RSpec.describe EmailPreferences do
  let(:user) { create(:user) }

  describe "#emailable?" do
    it "sends every category to a confirmed user by default" do
      (Email::Categories::OPTIONAL + ["account"]).each { |category| expect(user.emailable?(category)).to be(true) }
    end

    it "respects a category switched off" do
      user.update!(email_comments: false)

      expect(user.emailable?(:comments)).to be(false)
      expect(user.emailable?(:weekly)).to be(true)
    end

    it "sends only account mail to suppressed or unconfirmed addresses" do
      [create(:user, :unconfirmed), create(:user, email_suppressed_at: Time.current)].each do |recipient|
        expect(recipient.emailable?(:account)).to be(true)
        expect(recipient.emailable?(:weekly)).to be(false)
      end
    end

    it "rejects unknown categories" do
      expect(user.emailable?(:mystery)).to be(false)
    end
  end

  describe "unsubscribe tokens" do
    it "round-trips the user and category" do
      token = user.unsubscribe_token(:weekly)
      expect(User.from_unsubscribe_token(token)).to eq([user, "weekly"])
    end

    it "rejects tampered tokens and the account category" do
      expect(User.from_unsubscribe_token("#{user.unsubscribe_token(:weekly)}x")).to be_nil
      expect(User.from_unsubscribe_token(user.unsubscribe_token(:account))).to be_nil
    end

    it "turns off just that category" do
      user.unsubscribe_from!(:editorial)

      expect(user.reload.email_editorial).to be(false)
      expect(user.email_weekly).to be(true)
    end
  end

  it "suppresses and restores an address" do
    user.suppress_email!("bounce")
    expect(user).to be_email_suppressed

    user.unsuppress_email!
    expect(user.reload).not_to be_email_suppressed
    expect(user.email_suppression_reason).to be_nil
  end
end
