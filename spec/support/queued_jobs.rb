# Jobs run inline in the suite. Tag an example or group with :queued_jobs to enqueue them instead,
# for the have_enqueued_job / have_enqueued_mail matchers.
RSpec.configure do |config|
  config.around(:each, :queued_jobs) do |example|
    original = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original
  end
end
