class Tag < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation { self.slug = name&.strip }

  scope :popular, -> { order(articles_count: :desc) }
  scope :with_articles, -> { where("articles_count > 0") }

  def to_param
    slug
  end
end
