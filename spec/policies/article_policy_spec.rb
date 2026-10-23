require "rails_helper"

RSpec.describe ArticlePolicy do
  subject(:policy) { described_class }

  let(:author) { create(:user) }
  let(:other_user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }
  let(:article) { create(:article, :published, user: author) }
  let(:draft) { create(:article, :draft, user: author) }

  permissions :create? do
    it "allows confirmed users" do
      expect(policy).to permit(author, Article)
    end

    it "denies unconfirmed users and visitors" do
      expect(policy).not_to permit(create(:user, :unconfirmed), Article)
      expect(policy).not_to permit(nil, Article)
    end
  end

  permissions :update?, :edit?, :destroy? do
    it "allows the author, editors and admins" do
      expect(policy).to permit(author, article)
      expect(policy).to permit(editor, article)
      expect(policy).to permit(admin, article)
    end

    it "denies other users and visitors" do
      expect(policy).not_to permit(other_user, article)
      expect(policy).not_to permit(nil, article)
    end
  end

  permissions :show? do
    it "shows published articles to everyone" do
      expect(policy).to permit(nil, article)
      expect(policy).to permit(other_user, article)
    end

    it "shows drafts only to people who can edit them" do
      expect(policy).to permit(author, draft)
      expect(policy).to permit(editor, draft)
      expect(policy).not_to permit(other_user, draft)
      expect(policy).not_to permit(nil, draft)
    end
  end
end
