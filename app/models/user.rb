class User < ApplicationRecord
  extend FriendlyId

  friendly_id :email, use: :slugged

  has_many :articles, dependent: :destroy
  has_many :article_likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :comment_likes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :page_views, as: :viewable, dependent: :destroy
  has_many :liked_articles, through: :article_likes, source: :article
  has_many :bookmarked_articles, through: :bookmarks, source: :article
  has_many :sessions, dependent: :destroy
  has_many :reports_filed, class_name: "Report", foreign_key: :reporter_id, inverse_of: :reporter, dependent: :destroy
  has_many :reports_received, class_name: "Report", foreign_key: :reported_user_id, inverse_of: :reported_user,
                              dependent: :nullify
  has_many :magic_links, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, inverse_of: :recipient, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, inverse_of: :actor, dependent: :destroy

  has_many :follows_as_follower, class_name: "Follow", foreign_key: :follower_id, inverse_of: :follower, dependent: :destroy
  has_many :follows_as_followed, class_name: "Follow", as: :followable, dependent: :destroy

  has_many :following_users, through: :follows_as_follower, source: :followable, source_type: "User"
  has_many :following_tags, through: :follows_as_follower, source: :followable, source_type: "Tag"
  has_many :followers, through: :follows_as_followed, source: :follower

  has_one_attached :avatar

  has_person_name

  scope :featured, -> { where(featured: true) }
  scope :confirmed, -> { where(confirmed: true) }
  scope :unconfirmed, -> { where(confirmed: false) }
  scope :picked, -> { where(picked: true) }
  scope :editors, -> { where(editor: true) }
  scope :admins, -> { where(admin: true) }
  scope :suspended, -> { where.not(suspended_at: nil) }

  SOCIAL_HANDLES = %i[twitter_handle instagram_handle facebook_handle].freeze
  SOCIAL_PROFILE_URLS = {
    twitter_handle:   "https://x.com/",
    instagram_handle: "https://instagram.com/",
    facebook_handle:  "https://facebook.com/"
  }.freeze

  normalizes :email, with: ->(email) { email.downcase.strip }
  # Accept "@name" or a pasted profile URL, and store just the handle
  normalizes(*SOCIAL_HANDLES, with: lambda { |handle|
    handle.gsub(/[[:space:]]/, "")
          .sub(%r{\A(?:https?://)?(?:(?:www|m)\.)?(?:x|twitter|instagram|facebook)\.com/}i, "")
          .delete_prefix("@")
          .split(%r{[?#/]}).first
          .presence
  })
  # Add https:// when no scheme was typed, so "example.com" works
  normalizes :website_url, with: lambda { |url|
    url = url.strip
    if url.blank?
      nil
    elsif url.match?(/\A[a-z][a-z0-9+.-]*:/i)
      url
    else
      "https://#{url}"
    end
  }

  # Only http(s) links, so a profile can't carry a javascript: URL. Validated only when
  # changed, so older records with bad values don't block unrelated updates.
  validates :website_url, format:      { with:    %r{\Ahttps?://[^\s<>"']+\z}i,
                                         message: "يجب أن يكون رابطًا يبدأ بـ http أو https" },
                          length:      { maximum: 255 },
                          allow_blank: true,
                          if:          :website_url_changed?
  SOCIAL_HANDLES.each do |handle|
    validates handle, format:      { with:    /\A[A-Za-z0-9_.]{1,50}\z/,
                                     message: "يجب أن يحتوي على أحرف إنجليزية وأرقام و _ و . فقط" },
                      allow_blank: true,
                      if:          :"#{handle}_changed?"
  end

  validates :email, uniqueness: true, presence: true,
                    allow_blank: false, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :slug, uniqueness:  true,
                   presence:    true,
                   allow_blank: false,
                   length:      { minimum: 4, maximum: 50 },
                   format:      { with:    /\A(?![._-])(?=.*[a-zA-Z0-9])[-_a-zA-Z0-9]+(?<![._-])\z/,
                                  message: "إسم المستخدم يجب أن يكون أحرف مع أرقام، شرطة، \
  أو شرطة سفلية فقط، أيضًا، يجب ألا يبدأ أو ينتهي بعلامات" }
  validates :name, presence: true,
    allow_blank: false,
    length: { minimum: 3 }, on: :update

  validates :featured, inclusion: { in: [true, false] }, allow_nil: false

  validate :slug_is_not_reserved
  validate :correct_avatar_mime_type

  def send_magic_link(purpose:)
    magic_link = magic_links.create!(purpose: purpose)
    MagicLinkMailer.verification_code(magic_link).deliver_later
    magic_link
  end

  def feature
    update(featured: true)
  end

  def admin?
    admin
  end

  def editor?
    editor
  end

  # Writers to suggest following: editors' picks first, then featured writers, then the most-followed
  # writers with published articles. Skips the reader and anyone they already follow.
  def self.suggested_for(reader, limit: 4)
    candidates = where.not(id: reader.following_users.select(:id)).where.not(id: reader.id)

    suggestion_tiers(candidates).each_with_object([]) do |tier, suggested|
      break suggested if suggested.size >= limit

      suggested.concat(tier.where.not(id: suggested.map(&:id)).limit(limit - suggested.size).to_a)
    end
  end

  def self.suggestion_tiers(candidates)
    [
      candidates.picked.order(Arel.sql("RAND()")),
      candidates.featured.order(Arel.sql("RAND()")),
      candidates.where(id: Article.published.select(:user_id)).order(followers_count: :desc)
    ]
  end
  private_class_method :suggestion_tiers

  # Suspended users can sign in and read, but not publish, comment or like
  def suspended?
    suspended_at.present?
  end

  def suspend!(reason)
    update!(suspended_at: Time.current, suspension_reason: reason)
  end

  def unsuspend!
    update!(suspended_at: nil, suspension_reason: nil)
  end

  def make_admin
    update(admin: true)
  end

  def make_editor
    update(editor: true)
  end

  def following?(record)
    follows_as_follower.exists?(followable: record)
  end

  # Website URL safe to use as a link: only http(s) with a host, even for older unvalidated values
  def website_link
    uri = URI.parse(website_url.to_s.strip)
    uri.to_s if uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    nil
  end

  # Profile URL for a social handle, built only from a well-formed handle
  def social_link(handle)
    # Normalize on read too, so handles saved before normalization still link correctly
    value = self.class.normalize_value_for(handle, public_send(handle)).to_s
    "#{SOCIAL_PROFILE_URLS.fetch(handle)}#{ERB::Util.url_encode(value)}" if value.match?(/\A[A-Za-z0-9_.]{1,50}\z/)
  end

  private

  def correct_avatar_mime_type
    return unless avatar.attached?

    errors.add(:avatar, "يرجى ارفاق صورة فقط!") unless avatar.content_type.in?(%w[image/jpeg image/png image/*])
  end

  def slug_is_not_reserved
    forbid = Constraints::ReservedSlugs::RESERVED_SLUGS.map(&:downcase)

    errors.add(:slug, :exclusion) if forbid.find { |w| slug.eql?(w) }
  end
end
