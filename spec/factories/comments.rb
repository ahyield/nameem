FactoryBot.define do
  factory :comment do
    article
    user
    body { "هذا تعليق تجريبي" }
  end
end
