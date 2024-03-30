class User < ApplicationRecord
  extend FriendlyId
  friendly_id :email, use: :slugged

  has_many :articles, dependent: :destroy

  has_one_attached :avatar

  has_person_name

  scope :featured, -> { where(featured: true) }
  scope :confirmed, -> { where(confirmed: true) }
  scope :picked, -> { where(picked: true) }
  scope :editors, -> { where(editor: true) }
  scope :admins, -> { where(admin: true) }

  normalizes :email, with: ->(email) { email.downcase.strip }

  validates :email, uniqueness: true, presence: true,
                    allow_blank: false, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :slug, uniqueness:  true,
                   presence:    true,
                   allow_blank: false,
                   length:      { minimu: 4, maximum: 50 },
                   format:      { with:    /\A(?![._-])(?=.*[a-zA-Z0-9])[-_a-zA-Z0-9]+(?<![._-])\z/,
                                  message: "إسم المستخدم يجب أن يكون أحرف مع أرقام، شرطة، \
  أو شرطة سفلية فقط، أيضًا، يجب ألا يبدأ أو ينتهي بعلامات" }
  validate :slug_is_not_reserved
  validate :correct_avatar_mime_type

  generates_token_for :magic_login, expires_in: 15.minutes do
    last_sign_in_at
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

  def make_admin
    update(admin: true)
  end

  def make_editor
    update(editor: true)
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
