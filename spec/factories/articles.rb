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
  end
end
