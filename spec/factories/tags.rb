FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "موضوع-#{n}" }
  end
end
