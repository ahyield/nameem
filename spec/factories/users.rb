# Create factory for users
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    bio { Faker::Lorem.paragraph }
    confirmed { true }
    featured { false }
    last_sign_in_at { Time.zone.now }
    slug { Faker::Internet.slug }

    after(:create) do |user|
      url = Faker::Avatar.image(slug: Faker::Internet.slug, size: "50x50", format: "jpg")
      file = URI.parse(url).open
      filename = File.basename(URI.parse(url).path)

      user.avatar.attach(io: file, filename:)
    end

    trait :unconfirmed do
      confirmed { false }
    end

    trait :featured do
      featured { true }
    end

    trait :with_articles do
      transient do
        articles_count { 5 }
      end

      after(:create) do |user, evaluator|
        create_list(:article, evaluator.articles_count, user:)
      end
    end

    trait :picked do
      picked { true }
    end

    trait :admin do
      admin { true }
    end

    trait :editor do
      editor { true }
    end

    factory :user_with_articles, traits: [:with_articles]
    factory :user_with_avatar, traits: [:with_avatar]

    factory :admin, traits: [:admin]
    factory :editor, traits: [:editor]
  end
end
