module Announcements
  # Tells readers dark mode is here, once. Dry run by default; a test copy goes to one address; the real send
  # goes to everyone subscribed to «أخبار نميم» and is recorded so it can't go out twice.
  class DarkMode
    SENT_FLAG = :announcement_dark_mode_sent

    def self.audience
      User.where(email_news: true, confirmed: true, email_suppressed_at: nil)
    end

    def initialize(out: $stdout)
      @out = out
    end

    def run(to: nil, deliver: false, force: false)
      if to.present?
        test_copy(to)
      elsif deliver
        send_to_everyone(force:)
      else
        @out.puts "Would send to #{self.class.audience.count} readers. " \
                  "Run with TO=you@example.com for a test copy, SEND=1 to send."
      end
    end

    private

    def test_copy(email)
      user = User.find_by(email:) || raise(ArgumentError.new("No user with the email #{email}"))
      AnnouncementMailer.dark_mode(user).deliver_later
      @out.puts "Test copy queued for #{email}."
    end

    def send_to_everyone(force:)
      if Flipper.enabled?(SENT_FLAG) && !force
        @out.puts "Already sent. Run with FORCE=1 to send again."
        return
      end

      count = 0
      self.class.audience.find_each do |user|
        AnnouncementMailer.dark_mode(user).deliver_later
        count += 1
      end
      Flipper.enable(SENT_FLAG)
      @out.puts "Queued for #{count} readers."
    end
  end
end
