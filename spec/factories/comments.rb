FactoryBot.define do
  factory :comment do
    article
    user
    body { "هذا تعليق تجريبي" }

    trait :reply do
      association :parent, factory: :comment
    end
  end
end
