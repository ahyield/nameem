class Tag < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags
  has_many :follows, as: :followable, dependent: :destroy
  has_many :followers, through: :follows, source: :follower

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation { self.slug = name&.strip }

  scope :popular, -> { order(articles_count: :desc) }
  scope :with_articles, -> { where("articles_count > 0") }
  scope :with_published_counts, lambda {
    left_joins(articles: [])
      .select("tags.*, COUNT(CASE WHEN articles.published = 1 THEN 1 END) AS published_articles_count")
      .group("tags.id")
  }

  def to_param
    slug
  end
end
