class Article < ApplicationRecord
  # The site's own account; its articles are left out of popularity rankings
  RANKING_EXCLUDED_USER_ID = 1

  include Metable

  has_many_attached :images

  has_many :article_likes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  has_many :comments, dependent: :destroy
  has_many :page_views, as: :viewable, dependent: :destroy

  belongs_to :user

  scope :published, -> { where(published: true) }
  scope :picked, -> { where(picked: true) }
  scope :featured, -> { where(featured: true) }
  scope :drafts, -> { where(published: false) }
  # lol, easy way to fuck things up, however it works. User.find_by(id: 1) == `nameem`,
  # so we don't want articles from nameem to show up in most reads.
  scope :most_popular, lambda {
    where("published = ? AND user_id != ?", true, RANKING_EXCLUDED_USER_ID).order(real_views_count: :desc)
  }
  scope :related_to, lambda { |article, limit: 4|
    published
      .joins(:article_tags)
      .where(article_tags: { tag_id: article.tag_ids })
      .where.not(id: article.id)
      .select("articles.*, COUNT(article_tags.tag_id) as shared_tags_count")
      .group("articles.id")
      .order(Arel.sql("COUNT(article_tags.tag_id) DESC, articles.published_at DESC"))
      .limit(limit)
  }

  attribute :uuid, MySQLBinUUID::Type.new

  validates :featured, inclusion: { in: [true, false] }, allow_nil: false
  validates :published, inclusion: { in: [true, false] }, allow_nil: false
  validates :picked, inclusion: { in: [true, false] }, allow_nil: false
  validates :uuid, uniqueness: true

  def self.trending(days: 7)
    results = trending_within(days)
    return results if days >= 90 || results.exists?

    trending(days: days == 7 ? 30 : 90)
  end

  def self.trending_within(days)
    where("published = ? AND user_id != ? AND published_at >= ?", true, RANKING_EXCLUDED_USER_ID, days.days.ago)
      .select("articles.*, (real_views_count + likes_count * 3 + comments_count * 5) / " \
              "POW(TIMESTAMPDIFF(HOUR, published_at, NOW()) + 2, 1.5) AS trending_score")
      .order(Arel.sql("trending_score DESC, published_at DESC"))
  end

  def to_param
    uuid
  end

  def publish
    update_column(:published, true)
  end

  def unpublish
    update_column(:published, false)
  end

  def draft?
    !published?
  end

  def pick
    update(picked: true)
  end

  def feature
    update(featured: true)
  end

  after_update :notify_on_feature_or_pick

  private

  def notify_on_feature_or_pick
    actions = editorial_actions
    return if actions.empty?

    system_user = User.find_by(id: 1)
    return unless system_user

    actions.each do |action|
      Notification.create!(recipient: user, actor: system_user, notifiable: self, action:)
    end
  end

  # Notifications owed to the author for being featured or picked in this save
  def editorial_actions
    actions = []
    actions << :featured if saved_change_to_featured? && featured?
    actions << :picked if saved_change_to_picked? && picked?
    actions
  end
end
