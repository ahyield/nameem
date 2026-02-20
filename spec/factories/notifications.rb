FactoryBot.define do
  factory :notification do
    recipient factory: :user
    actor factory: :user
    action { :featured }
    notifiable { association(:article, user: recipient) }

    trait :liked do
      action { :liked }
    end

    trait :commented do
      action { :commented }
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
