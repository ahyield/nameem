require "rails_helper"

RSpec.describe WeeklyDigestMailer do
  let(:reader) { create(:user) }

  it "lists the week's best articles, picks and writers with one-click unsubscribe" do
    trending = create(:article, :published, published_at: 1.day.ago, title: "موضوع الأسبوع", description: "وصف قصير",
                                            reading_time_minutes: 4)
    picked = create(:article, :published, :picked, published_at: 2.days.ago, title: "اختيار المحرر")
    digest = WeeklyDigest.current
    allow(digest).to receive(:trending).and_return([trending])
    writer = create(:user, :picked, first_name: "كاتب")

    mail = described_class.best_of(reader, digest)
    body = mail.html_part.body.decoded

    expect(mail.subject).to eq("حصاد الأسبوع على نميم")
    expect(body).to include("الأوسع صدى", "موضوع الأسبوع", "وصف قصير", "قراءة 4 دقائق", "اختيار المحرر", writer.name)
    expect(body).not_to include(picked.user.email)
    expect(mail["List-Unsubscribe"].to_s).to include("/email/unsubscribe/one-click?token=")
  end

  it "falls back to the opening text for untitled articles and skips empty sections" do
    untitled = create(:article, :published, published_at: 1.day.ago, title: nil, description: nil,
                                            reading_time_minutes: nil, content_html: "<p>بداية النص</p>")
    digest = WeeklyDigest.current
    allow(digest).to receive_messages(trending: [untitled], picks: [])
    allow(User).to receive(:suggested_for).and_return([])

    body = described_class.best_of(reader, digest).html_part.body.decoded

    expect(body).to include("بداية النص")
    expect(body).not_to include("اختيارات المحررين</p>", "كتّاب قد يعجبونك</p>")
  end

  it "crops the lead image and thumbnails on the server" do
    lead, second = create_list(:article, 2, :published, :with_images, published_at: 1.day.ago)
    digest = WeeklyDigest.current
    allow(digest).to receive(:trending).and_return([lead, second])

    body = described_class.best_of(reader, digest).html_part.body.decoded

    expect(body.scan(%r{/rails/active_storage/representations/}).size).to eq(2)
    expect(body).to include("الأوسع صدى", "02")
  end

  it "is not delivered to readers who unsubscribed" do
    reader.update!(email_weekly: false)
    message = described_class.best_of(reader, WeeklyDigest.current)

    expect { message.deliver_now }.not_to change(ActionMailer::Base.deliveries, :count)
  end
end
