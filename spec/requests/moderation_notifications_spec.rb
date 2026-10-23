require "rails_helper"

RSpec.describe "Moderation notices" do
  let(:author) { create(:user) }
  let(:reporter) { create(:user) }
  let(:article) { create(:article, :published, user: author, title: "عنوان الموضوع") }
  let(:report) { create(:report, reporter:, reportable: create(:comment, article:, user: author, body: "نص محذوف")) }

  it "shows the author what was removed, signed by the team" do
    create(:notification, recipient: author, notifiable: report, action: :content_removed)
    authenticate_user(author)

    get notifications_path

    expect(response.body).to include("فريق نميم")
    expect(response.body).to include("نص محذوف")
  end

  it "tells the reporter their report was acted on" do
    create(:notification, recipient: reporter, notifiable: report, action: :report_actioned)
    authenticate_user(reporter)

    get notifications_path

    expect(response.body).to include("راجع بلاغك")
    expect(response.body).to include("عنوان الموضوع")
  end

  it "includes moderation notices in the daily digest" do
    notification = create(:notification, recipient: reporter, notifiable: report, action: :report_actioned)

    mail = NotificationMailer.digest(reporter, [notification])
    expect(mail.html_part&.body&.to_s || mail.body.to_s).to include("فريق نميم")
  end
end
