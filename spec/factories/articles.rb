# This file contains the factory for the Article model.
require "securerandom"

FactoryBot.define do
  factory :article do
    title { "New Article" }
    content { { ops: [{ insert: "New Article" }] } }
    slug { "slug-article" }
    user
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
        article.images.attach(io:           Rails.root.join("spec/fixtures/files/avatar-3.jpeg").open,
                              filename:     "image.jpeg",
                              content_type: "image/jpeg")
      end
    end

    trait :comments_disabled do
      comments_enabled { false }
    end

    trait :draft do
      published { false }
    end
  end
end
