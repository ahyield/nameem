class Article < ApplicationRecord
  include Metable

  has_many_attached :images

  has_many :article_likes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  has_many :comments, dependent: :destroy

  belongs_to :user

  scope :published, -> { where(published: true) }
  scope :picked, -> { where(picked: true) }
  scope :featured, -> { where(featured: true) }
  scope :drafts, -> { where(published: false) }
  # lol, easy way to fuck things up, however it works. User.find_by(id: 1) == `nameem`,
  # so we don't want articles from nameem to show up in most reads.
  scope :most_popular, -> { where("published = ? AND user_id != ?", true, 1).order(views_count: :desc) }
  scope :most_visited, -> { where("published = ? AND user_id != ?", true, 1).order(visitors_count: :desc) }

  scope :related_to, ->(article, limit: 4) {
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
    system_user = User.find_by(id: 1)
    return unless system_user

    if saved_change_to_featured? && featured?
      Notification.create!(
        recipient:  user,
        actor:      system_user,
        notifiable: self,
        action:     :featured
      )
    end

    if saved_change_to_picked? && picked?
      Notification.create!(
        recipient:  user,
        actor:      system_user,
        notifiable: self,
        action:     :picked
      )
    end
  end
end
