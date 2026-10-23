require "rails_helper"

RSpec.describe "Backoffice::Reports" do
  let(:editor) { create(:editor) }
  let(:author) { create(:user, first_name: "كاتب") }
  let(:article) { create(:article, :published, user: author, title: "موضوع مُبلّغ عنه") }
  let(:comment) { create(:comment, article:, user: author, body: "تعليق مسيء جداً") }
  let!(:comment_reports) { create_list(:report, 2, reportable: comment) }
  let!(:article_report) { create(:report, reportable: article, reason: :plagiarism) }

  before { authenticate_user(editor) }

  describe "GET /backoffice/reports" do
    it "lists one row per reported item, most reported first" do
      get backoffice_reports_path

      expect(response).to have_http_status(:ok)
      expect(response.body.scan("bo-row").size).to eq(2)
      expect(response.body.index("تعليق مسيء جداً")).to be < response.body.index("موضوع مُبلّغ عنه")
      expect(response.body).to include("محتوى مزعج أو إعلاني (2)")
    end

    it "filters by type and status" do
      get backoffice_reports_path(filter: "articles")
      expect(response.body).to include("موضوع مُبلّغ عنه")
      expect(response.body).not_to include("تعليق مسيء جداً")

      get backoffice_reports_path(filter: "comments")
      expect(response.body).to include("تعليق مسيء جداً")

      article_report.dismissed!
      get backoffice_reports_path(filter: "resolved")
      expect(response.body).to include("موضوع مُبلّغ عنه")
      expect(response.body).not_to include("تعليق مسيء جداً")

      get backoffice_reports_path(filter: "all")
      expect(response.body.scan("bo-row").size).to eq(2)
    end

    it "searches the reported text and author" do
      get backoffice_reports_path(q: "مسيء")
      expect(response.body).not_to include("موضوع مُبلّغ عنه")

      get backoffice_reports_path(q: "كاتب")
      expect(response.body.scan("bo-row").size).to eq(2)
    end

    it "shows an empty state" do
      Report.delete_all
      get backoffice_reports_path
      expect(response.body).to include("لا توجد بلاغات بانتظار المراجعة")
    end

    it "badges the nav with the pending count" do
      get backoffice_reports_path
      expect(response.body).to match(%r{البلاغات\s*<span[^>]*>3</span>})
    end
  end

  describe "GET /backoffice/reports/:id" do
    it "shows the comment and every report against it" do
      get backoffice_report_path(comment_reports.first)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("تعليق مسيء جداً")
      comment_reports.each { |report| expect(response.body).to include("report_#{report.id}") }
      expect(response.body).to include("حذف التعليق")
    end

    it "shows the article with its published state" do
      get backoffice_report_path(article_report)

      expect(response.body).to include("موضوع مُبلّغ عنه")
      expect(response.body).to include("إلغاء نشر الموضوع")
    end

    it "falls back to the snapshot once the content is gone" do
      comment.destroy
      get backoffice_report_path(comment_reports.first)

      expect(response.body).to include("تعليق مسيء جداً")
      expect(response.body).to include("حُذف هذا المحتوى")
    end

    it "copes with an author whose account is gone" do
      comment_reports.first.update_column(:reported_user_id, nil)
      get backoffice_report_path(comment_reports.first)

      expect(response.body).to include("مستخدم محذوف")
    end

    it "shows the author's history and past decisions" do
      create(:report, :actioned, reportable: create(:comment, user: author), reviewer: editor, reviewed_at: 1.day.ago,
                                 resolution_note: "مخالفة واضحة")
      article_report.update!(status: :dismissed, reviewer: editor, reviewed_at: Time.current, resolution_note: "لا مخالفة")

      get backoffice_report_path(article_report)

      expect(response.body).to include("سبق اتخاذ إجراء ضد 1")
      expect(response.body).to include("لا مخالفة")
      expect(response.body).not_to include("حفظ القرار")
    end
  end

  describe "POST /backoffice/reports/:id/resolve" do
    it "acts on all reports about the item" do
      post resolve_backoffice_report_path(comment_reports.first),
           params: { decision: "action", remove_content: "1", warn_author: "1", notify_reporters: "1" }

      expect(response).to redirect_to(backoffice_reports_path)
      expect(Comment.exists?(comment.id)).to be(false)
      expect(comment_reports.map(&:reload)).to all(be_actioned)
      expect(article_report.reload).to be_pending
    end

    it "dismisses" do
      post resolve_backoffice_report_path(article_report), params: { decision: "dismiss", note: "لا مخالفة" }

      expect(article_report.reload).to have_attributes(status: "dismissed", resolution_note: "لا مخالفة", reviewer: editor)
      expect(article.reload).to be_published
    end

    it "says when the reports were already handled" do
      article_report.dismissed!
      post resolve_backoffice_report_path(article_report), params: { decision: "action" }

      expect(flash[:notice]).to eq("تمت مراجعة هذا البلاغ مسبقاً")
    end

    it "lets an admin suspend the author" do
      authenticate_user(create(:admin))
      get backoffice_report_path(article_report)
      expect(response.body).to include("إيقاف حساب الكاتب")

      post resolve_backoffice_report_path(article_report), params: { decision: "action", suspend_author: "1" }
      expect(author.reload).to be_suspended
    end

    it "does not offer suspension to editors" do
      get backoffice_report_path(article_report)
      expect(response.body).not_to include("إيقاف حساب الكاتب")
    end

    it "asks for a decision" do
      post resolve_backoffice_report_path(article_report), params: { decision: "" }

      expect(response).to redirect_to(backoffice_report_path(article_report))
      expect(article_report.reload).to be_pending
    end
  end

  it "keeps readers out" do
    authenticate_user(create(:user))

    get backoffice_reports_path
    expect(response).to redirect_to("/")
  end

  it "counts pending reports on the dashboard" do
    get backoffice_root_path
    expect(response.body).to include("بلاغات معلقة")
  end
end
