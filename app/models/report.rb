class Report < ApplicationRecord
  # Content readers can report; the keys are the only reportable_type values accepted from requests
  REPORTABLE_TYPES = %w[Article Comment].freeze

  REASONS = {
    "spam"           => "محتوى مزعج أو إعلاني",
    "harassment"     => "تحرش أو إساءة",
    "hate"           => "خطاب كراهية",
    "sexual"         => "محتوى جنسي",
    "violence"       => "عنف أو تهديد",
    "misinformation" => "معلومات مضللة",
    "plagiarism"     => "سرقة أدبية",
    "other"          => "سبب آخر"
  }.freeze

  belongs_to :reporter, class_name: "User"
  belongs_to :reportable, polymorphic: true, optional: true # reports outlive deleted content
  belongs_to :reported_user, class_name: "User", optional: true
  belongs_to :reviewer, class_name: "User", optional: true

  has_many :notifications, as: :notifiable, dependent: :destroy

  enum :reason, { spam: 0, harassment: 1, hate: 2, sexual: 3, violence: 4, misinformation: 5, plagiarism: 6, other: 7 },
       validate: true
  enum :status, { pending: 0, actioned: 1, dismissed: 2 }

  validates :reportable_type, inclusion: { in: REPORTABLE_TYPES }
  validates :reportable_id, uniqueness: { scope: %i[reporter_id reportable_type] }
  validates :details, length: { maximum: 500 }
  validates :details, presence: true, if: :other?
  validate :not_own_content, on: :create

  before_create :capture_content

  scope :resolved, -> { where(status: %i[actioned dismissed]) }
  scope :for_item, ->(report) { where(reportable_type: report.reportable_type, reportable_id: report.reportable_id) }

  def reason_label
    REASONS[reason]
  end

  # The article the reported content lives on, if it still exists
  def article
    reportable.is_a?(Comment) ? reportable.article : reportable
  end

  private

  def not_own_content
    return unless REPORTABLE_TYPES.include?(reportable_type) && reportable

    errors.add(:base, "لا يمكنك الإبلاغ عن محتواك") if reportable.user_id == reporter_id
  end

  def capture_content
    self.reported_user_id = reportable.user_id
    self.snapshot = if reportable.is_a?(Comment)
                      reportable.body.to_plain_text.truncate(2000)
                    else
                      [reportable.title, reportable.description].compact_blank.join(" — ")
                    end
  end
end
