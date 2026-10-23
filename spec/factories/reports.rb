FactoryBot.define do
  factory :report do
    reporter factory: :user
    reportable factory: %i[comment]
    reason { :spam }

    trait :on_article do
      reportable factory: %i[article published]
    end

    # FactoryBot defines a trait per enum value; "other" also needs details
    trait :other do
      reason { :other }
      details { "سبب لم يرد في القائمة" }
    end

    trait :actioned do
      status { :actioned }
    end
  end
end
