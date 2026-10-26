module Email
  # Kinds of email Nameem sends. Every category except "account" has a user column readers can turn off,
  # a one-click unsubscribe link and a List-Unsubscribe header.
  module Categories
    ALL = {
      "account"         => { column: nil },
      "activity_digest" => {
        column:      :email_notifications,
        label:       "ملخص النشاط اليومي",
        description: "رسالة واحدة صباحاً بالإعجابات والمتابعات وما فاتك.",
        reason:      "تصلك هذه الرسالة لأنك مشترك في ملخص النشاط اليومي."
      },
      "comments"        => {
        column:      :email_comments,
        label:       "التعليقات والردود",
        description: "رسالة فورية عندما يعلّق أحد على موضوعك أو يرد عليك.",
        reason:      "تصلك هذه الرسالة لأنك مشترك في رسائل التعليقات والردود."
      },
      "editorial"       => {
        column:      :email_editorial,
        label:       "اختيارات المحررين",
        description: "عندما يُميَّز موضوعك أو يختاره المحررون.",
        reason:      "تصلك هذه الرسالة لأنك مشترك في رسائل اختيارات المحررين."
      },
      "news"            => {
        column:      :email_news,
        label:       "أخبار نميم",
        description: "رسائل نادرة عن الجديد في نميم.",
        reason:      "تصلك هذه الرسالة لأنك مشترك في أخبار نميم."
      },
      "weekly"          => {
        column:      :email_weekly,
        label:       "حصاد الأسبوع",
        description: "رسالة كل جمعة بما لقي صدى على نميم، واختيارات المحررين، وكتّاب جدد.",
        reason:      "تصلك هذه الرسالة لأنك مشترك في نشرة حصاد الأسبوع."
      }
    }.freeze

    OPTIONAL = (ALL.keys - ["account"]).freeze

    def self.column(category)
      ALL.dig(category.to_s, :column)
    end

    def self.reason(category)
      ALL.dig(category.to_s, :reason)
    end

    def self.verifier
      Rails.application.message_verifier(:email_unsubscribe)
    end
  end
end
