class ArticleLike < ApplicationRecord
  belongs_to :article, counter_cache: :likes_count
  belongs_to :user

  validates :user_id, uniqueness: { scope: :article_id }
end
