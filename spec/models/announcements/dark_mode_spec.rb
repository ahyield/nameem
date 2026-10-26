require "rails_helper"

RSpec.describe Announcements::DarkMode, :queued_jobs do
  subject(:announcement) { described_class.new(out:) }

  let(:out) { StringIO.new }
  let!(:subscriber) { create(:user, confirmed: true) }

  before do
    create(:user, confirmed: true, email_news: false)
    create(:user, confirmed: true, email_suppressed_at: Time.current)
    create(:user, confirmed: false)
  end

  it "only counts the readers it would reach, without sending" do
    expect { announcement.run }.not_to have_enqueued_mail(AnnouncementMailer, :dark_mode)
    expect(out.string).to include("Would send to 1 readers")
  end

  it "sends a single test copy" do
    expect { announcement.run(to: subscriber.email) }
      .to have_enqueued_mail(AnnouncementMailer, :dark_mode).with(subscriber).once
    expect { announcement.run(to: "nobody@example.com") }.to raise_error(ArgumentError)
  end

  it "sends to «أخبار نميم» subscribers once, unless forced" do
    expect { announcement.run(deliver: true) }.to have_enqueued_mail(AnnouncementMailer, :dark_mode).once
    expect(Flipper.enabled?(described_class::SENT_FLAG)).to be(true)

    expect { announcement.run(deliver: true) }.not_to have_enqueued_mail(AnnouncementMailer, :dark_mode)
    expect(out.string).to include("Already sent")

    expect { announcement.run(deliver: true, force: true) }.to have_enqueued_mail(AnnouncementMailer, :dark_mode).once
  ensure
    Flipper.disable(described_class::SENT_FLAG)
  end
end
