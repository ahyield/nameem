require "rails_helper"

RSpec.describe "Reporting content" do
  let(:author) { create(:user) }
  let(:reader) { create(:user) }
  let(:article) { create(:article, :published, user: author) }
  let(:comment) { create(:comment, article:, user: author) }

  def report(type, id, reason: "spam", details: nil)
    post reports_path,
         params: { reportable_type: type, reportable_id: id, report: { reason:, details: }.compact },
         as:     :turbo_stream
  end

  context "when signed in" do
    before { authenticate_user(reader) }

    it "reports a comment" do
      expect { report("Comment", comment.id) }.to change(Report, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("وصلنا بلاغك")
      expect(Report.last).to have_attributes(reporter: reader, reportable: comment, reason: "spam")
    end

    it "reports an article by its uuid" do
      expect { report("Article", article.uuid, reason: "plagiarism") }.to change(Report, :count).by(1)
      expect(Report.last.reportable).to eq(article)
    end

    it "thanks a reader who reports the same item twice without a second report" do
      report("Comment", comment.id)

      expect { report("Comment", comment.id, reason: "hate") }.not_to change(Report, :count)
      expect(response).to have_http_status(:ok)
    end

    it "refuses reports on your own content" do
      authenticate_user(author)

      expect { report("Comment", comment.id) }.not_to change(Report, :count)
      expect(response).to have_http_status(:forbidden)
    end

    it "needs details when the reason is other" do
      report("Comment", comment.id, reason: "other")
      expect(response).to have_http_status(:unprocessable_content)

      report("Comment", comment.id, reason: "other", details: "شرح المشكلة")
      expect(response).to have_http_status(:ok)
    end

    it "ignores types outside the allowlist" do
      expect { report("User", author.id) }.not_to change(Report, :count)
      expect(response).to have_http_status(:not_found)
    end

    it "does not accept reports on drafts" do
      draft = create(:article, :draft, user: author)

      report("Article", draft.uuid)
      expect(response).to have_http_status(:not_found)
    end
  end

  it "requires signing in" do
    expect { report("Comment", comment.id) }.not_to change(Report, :count)
  end

  describe "the article page" do
    it "offers reporting the article and others' comments to readers" do
      create(:comment, article:, user: author)
      authenticate_user(reader)

      get user_article_path(slug: author.slug, uuid: article.uuid)

      expect(response.body).to include("الإبلاغ عن الموضوع")
      expect(response.body).to include('data-report-type-param="Comment"')
      expect(response.body).to include("<dialog")
    end

    it "offers no reporting to the author" do
      create(:comment, article:, user: author)
      authenticate_user(author)

      get user_article_path(slug: author.slug, uuid: article.uuid)

      expect(response.body).not_to include("الإبلاغ عن الموضوع")
      expect(response.body).not_to include('data-report-type-param="Comment"')
    end
  end
end
