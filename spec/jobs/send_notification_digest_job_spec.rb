require "rails_helper"

RSpec.describe SendNotificationDigestJob, type: :job do
  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
    ActiveJob::Base.queue_adapter = original_adapter
  end

  describe "#perform" do
    it "sends digest to users with recent unread notifications" do
      user = create(:user, email_notifications: true)
      create(:notification, recipient: user, created_at: 1.hour.ago)

      expect do
        described_class.perform_now
      end.to have_enqueued_mail(NotificationMailer, :digest)
    end

    it "skips users with email_notifications disabled" do
      user = create(:user, email_notifications: false)
      create(:notification, recipient: user, created_at: 1.hour.ago)

      expect do
        described_class.perform_now
      end.not_to have_enqueued_mail(NotificationMailer, :digest)
    end

    it "skips users with no recent unread notifications" do
      user = create(:user, email_notifications: true)
      create(:notification, recipient: user, created_at: 2.days.ago)

      expect do
        described_class.perform_now
      end.not_to have_enqueued_mail(NotificationMailer, :digest)
    end

    it "skips users with only read notifications" do
      user = create(:user, email_notifications: true)
      create(:notification, :read, recipient: user, created_at: 1.hour.ago)

      expect do
        described_class.perform_now
      end.not_to have_enqueued_mail(NotificationMailer, :digest)
    end
  end
end
