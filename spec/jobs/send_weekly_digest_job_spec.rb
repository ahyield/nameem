require "rails_helper"

RSpec.describe SendWeeklyDigestJob, :queued_jobs do
  let!(:subscriber) { create(:user) }

  before { create(:user, email_weekly: false) }

  it "emails every subscriber when the week had enough articles" do
    3.times { create(:article, :published, published_at: 1.day.ago) }

    expect { described_class.perform_now }.to have_enqueued_mail(WeeklyDigestMailer, :best_of).with(subscriber)
  end

  it "skips a quiet week" do
    create(:article, :published, published_at: 1.day.ago)

    expect { described_class.perform_now }.not_to have_enqueued_mail(WeeklyDigestMailer, :best_of)
  end
end
