require "rails_helper"

RSpec.describe Report do
  let(:author) { create(:user) }
  let(:comment) { create(:comment, user: author, body: "تعليق مسيء") }

  describe "validations" do
    subject { build(:report, reportable: comment) }

    it { is_expected.to validate_length_of(:details).is_at_most(500) }

    it "only accepts articles and comments" do
      expect(build(:report, reportable: create(:user))).not_to be_valid
    end

    it "lets a reader report an item once" do
      report = create(:report, reportable: comment)
      duplicate = build(:report, reporter: report.reporter, reportable: comment)

      expect(duplicate).not_to be_valid
    end

    it "needs details when the reason is other" do
      report = build(:report, reportable: comment, reason: :other)
      expect(report).not_to be_valid

      report.details = "شرح"
      expect(report).to be_valid
    end

    it "rejects unknown reasons" do
      expect(build(:report, reportable: comment, reason: "nonsense")).not_to be_valid
    end

    it "refuses reports on your own content" do
      expect(build(:report, reporter: author, reportable: comment)).not_to be_valid
    end
  end

  describe "on create" do
    it "keeps the comment text and its author" do
      report = create(:report, reportable: comment)

      expect(report.snapshot).to eq("تعليق مسيء")
      expect(report.reported_user).to eq(author)
    end

    it "keeps the article title and description" do
      article = create(:article, :published, title: "العنوان", description: "الوصف")
      report = create(:report, reportable: article)

      expect(report.snapshot).to eq("العنوان — الوصف")
    end

    it "survives the content being deleted" do
      report = create(:report, reportable: comment)
      comment.destroy

      expect(report.reload.reportable).to be_nil
      expect(report.snapshot).to eq("تعليق مسيء")
    end
  end

  describe "#article" do
    it "is the comment's article for a comment" do
      expect(create(:report, reportable: comment).article).to eq(comment.article)
    end

    it "is the article itself for an article" do
      article = create(:article, :published)
      expect(create(:report, reportable: article).article).to eq(article)
    end
  end

  describe "scopes" do
    it "finds reports about the same item and resolved ones" do
      first = create(:report, reportable: comment)
      second = create(:report, reportable: comment, status: :dismissed)
      create(:report)

      expect(described_class.for_item(first)).to contain_exactly(first, second)
      expect(described_class.resolved).to contain_exactly(second)
    end
  end

  it "labels its reason in Arabic" do
    expect(build(:report, reason: :hate).reason_label).to eq("خطاب كراهية")
  end
end
