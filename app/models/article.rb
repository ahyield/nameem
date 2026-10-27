class Article < ApplicationRecord
  # The site's own account; its articles are left out of popularity rankings
  RANKING_EXCLUDED_USER_ID = 1

  include Metable
  include Permalinkable
  include SeoSettings

  has_many_attached :images

  has_many :article_likes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags
  has_many :comments, dependent: :destroy
  has_many :page_views, as: :viewable, dependent: :destroy
  # Reports outlive the content so moderators keep the evidence
  has_many :reports, as: :reportable, dependent: nil

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

  attribute :uuid, MySQLBinUUID::Type.new

  validates :featured, inclusion: { in: [true, false] }, allow_nil: false
  validates :published, inclusion: { in: [true, false] }, allow_nil: false
  validates :picked, inclusion: { in: [true, false] }, allow_nil: false
  validates :comments_enabled, inclusion: { in: [true, false] }, allow_nil: false
  validates :uuid, uniqueness: true

  # Ranked by recent engagement (see Trending); only articles that are trending right now
  scope :trending, -> { published.where.not(trending_rank: nil).order(:trending_rank) }

  NEWCOMER_WINDOW = 24.hours

  # Articles from the last day that aren't trending yet, one per author, newest first. They get labelled
  # «جديد» slots in الرائج so they can be found before they have any engagement. Mostly-English
  # articles don't get a slot (Nameem is Arabic first).
  def self.newcomers(limit:)
    published.where(published_at: NEWCOMER_WINDOW.ago.., trending_rank: nil, mostly_latin: false)
             .where.not(user_id: RANKING_EXCLUDED_USER_ID)
             .includes(:user).order(published_at: :desc)
             .to_a.uniq(&:user_id).first(limit)
  end

  def to_param
    uuid
  end

  # Gives articles saved before readable URLs and fuller summaries their slug and description, without
  # touching updated_at. Returns how many changed.
  def self.backfill_seo
    find_each.count do |article|
      changes = article.seo_backfill
      article.update_columns(changes) if changes.any?
      changes.any?
    end
  end

  def seo_backfill
    doc = Nokogiri::HTML.fragment(content_html.to_s)
    summary = content_summary(doc)
    changes = {}
    changes[:slug] = permalink_slug if slug.blank? && permalink_slug
    if summary && summary != description && (description.blank? || description == legacy_content_summary(doc))
      changes[:description] = summary
    end
    changes
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
