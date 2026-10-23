require "rails_helper"

RSpec.describe ActivityMailer do
  let(:author) { create(:user) }
  let(:commenter) { create(:user, first_name: "معلّق") }
  let(:article) { create(:article, :published, user: author, title: "عن البحر") }

  it "emails the author about a comment with an excerpt" do
    comment = create(:comment, article:, user: commenter, body: "كتابة جميلة")
    mail = described_class.comment(Notification.find_by!(notifiable: comment))

    expect(mail.to).to eq([author.email])
    expect(mail.subject).to include("معلّق", "عن البحر")
    expect(mail.html_part.body.decoded).to include("كتابة جميلة", "اقرأ التعليق")
    expect(mail["List-Unsubscribe"].to_s).to include("/email/unsubscribe")
  end

  it "words replies differently" do
    parent = create(:comment, article:, user: author)
    reply = create(:comment, article:, user: commenter, parent:)
    mail = described_class.comment(Notification.find_by!(notifiable: reply, action: :replied))

    expect(mail.subject).to include("ردّ على تعليقك")
  end

  it "celebrates featured and picked articles" do
    featured = create(:notification, recipient: author, notifiable: article, action: :featured)
    picked = create(:notification, recipient: author, notifiable: article, action: :picked)

    expect(described_class.editorial(featured).subject).to start_with("مُيِّز موضوعك")
    expect(described_class.editorial(picked).subject).to start_with("اختار المحررون")
    article.update!(title: nil)
    expect(described_class.editorial(picked).subject).to include("بدون عنوان")
  end
end
