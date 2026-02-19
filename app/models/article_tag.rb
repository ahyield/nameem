class ArticleTag < ApplicationRecord
  belongs_to :article
  belongs_to :tag, counter_cache: :articles_count

  validates :tag_id, uniqueness: { scope: :article_id }
end
