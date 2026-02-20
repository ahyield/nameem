FactoryBot.define do
  factory :follow do
    follower factory: :user
    followable factory: :user

    trait :tag_follow do
      followable factory: :tag
    end
  end
end
