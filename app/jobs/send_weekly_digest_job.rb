# Fridays at 10am Cairo time (config/schedule.yml)
class SendWeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform
    digest = WeeklyDigest.current
    return unless digest.worth_sending?

    digest.audience.find_each { |user| WeeklyDigestMailer.best_of(user).deliver_later }
  end
end
