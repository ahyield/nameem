require "rails_helper"

RSpec.describe UserPolicy do
  subject(:policy) { described_class }

  let(:user) { create(:user) }

  permissions :edit?, :update?, :drafts?, :stats?, :bookmarks? do
    it "allows the user themselves" do
      expect(policy).to permit(user, user)
    end

    it "denies everyone else, including admins and visitors" do
      expect(policy).not_to permit(create(:user), user)
      expect(policy).not_to permit(create(:user, :admin), user)
      expect(policy).not_to permit(nil, user)
    end
  end

  permissions :index?, :show?, :create?, :destroy? do
    it "is never granted by default" do
      expect(policy).not_to permit(user, user)
    end
  end
end
