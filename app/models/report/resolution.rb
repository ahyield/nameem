class Report
  # Resolves every pending report against one piece of content in a single decision
  class Resolution
    DECISIONS = %w[action dismiss].freeze

    attr_reader :report, :reviewer, :decision, :note

    # actions: remove_content, warn_author, notify_reporters, suspend_author (booleans, used when the decision
    # is "action"); only admins can suspend
    def initialize(report, reviewer:, decision:, note: nil, **actions)
      @report = report
      @reviewer = reviewer
      @decision = decision.to_s
      @note = note.presence
      @actions = actions
    end

    def valid?
      DECISIONS.include?(decision)
    end

    # Returns the reports it resolved (empty when they were already handled)
    def call
      return [] unless valid?

      reports = Report.pending.for_item(report).includes(:reporter).to_a
      return [] if reports.empty?

      Report.transaction do
        take_action(reports) if decision == "action"
        Report.where(id: reports.map(&:id))
              .update_all(status: status, reviewer_id: reviewer.id, reviewed_at: Time.current, resolution_note: note)
      end
      reports
    end

    private

    def status
      decision == "action" ? :actioned : :dismissed
    end

    def take_action(reports)
      remove_content if @actions[:remove_content] && report.reportable
      act_on_author(reports.first) if report.reported_user
      reports.each { |filed| notify(filed.reporter, :report_actioned, filed) } if @actions[:notify_reporters]
    end

    def act_on_author(filed)
      report.reported_user.suspend!(note || "مخالفة إرشادات النشر") if @actions[:suspend_author] && reviewer.admin?
      notify(report.reported_user, :content_removed, filed) if @actions[:warn_author]
    end

    def remove_content
      if report.reportable.is_a?(Comment)
        report.reportable.destroy!
      else
        report.reportable.unpublish
      end
    end

    # Moderation notices come from the site account so reviewers stay anonymous
    def notify(recipient, action, notifiable)
      Notification.create!(recipient:, actor: system_user, notifiable:, action:)
    end

    def system_user
      @system_user ||= User.find_by(id: 1) || reviewer
    end
  end
end
