# This file contains the factory for the Article model.
require "securerandom"

FactoryBot.define do
  factory :article do
    title { "New Article" }
    content { { ops: [{ insert: "New Article" }] } }
    slug { "slug-article" }
    user { User.create(email: "test@test.com", slug: "test") }
    uuid { SecureRandom.uuid }
    published_at { DateTime.now }
    featured { false }
    picked { false }
    published { false }
    description { "article" }

    trait :published do
      published { true }
    end

    trait :featured do
      featured { true }
    end

    trait :picked do
      picked { true }
    end

    trait :with_images do
      after(:create) do |article|
        article.images.attach(io:           Rails.root.join("spec", "fixtures", "files", "avatar.png").open,
                              filename:     "image.jpg",
                              content_type: "image/jgp")
      end
    end

    factory :published_article, traits: [:published]
    factory :featured_article, traits: [:featured]
    factory :picked_article, traits: [:picked]
    factory :article_with_images, traits: [:with_images]
  end
end
