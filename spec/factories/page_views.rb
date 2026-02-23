FactoryBot.define do
  factory :page_view do
    association :viewable, factory: [:article, :published]
    visitor_id { SecureRandom.hex(16) }
  end
end
