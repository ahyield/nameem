FactoryBot.define do
  factory :comment do
    article
    user
    body { "هذا تعليق تجريبي" }

    # A reply lives on the same article as the comment it answers
    trait :reply do
      parent { association :comment, article: }
    end
  end
end
