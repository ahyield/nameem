class User < ApplicationRecord
  extend FriendlyId
  friendly_id :email, use: :slugged

  has_many :articles, dependent: :destroy

  has_one_attached :avatar

  has_person_name

  scope :featured, -> { where(featured: true) }

  normalizes :email, with: ->(email) { email.downcase.strip }

  validates :email, uniqueness: true
  validates :slug, uniqueness:  true,
                   presence:    true,
                   allow_blank: false,
                   length:      { minimu: 4, maximum: 50 },
                   format:      { with:    /\A(?![._-])(?=.*[a-zA-Z0-9])[-_a-zA-Z0-9]+(?<![._-])\z/,
                                  message: "إسم المستخدم يجب أن يكون أحرف مع أرقام، شرطة، \
  أو شرطة سفلية فقط، أيضًا، يجب ألا يبدأ أو ينتهي بعلامات" }
  validate :slug_is_not_reserved

  generates_token_for :magic_login, expires_in: 15.minutes do
    last_sign_in_at
  end

  def feature
    update(featured: true)
  end

  private

  def slug_is_not_reserved
    forbid = Constraints::ReservedSlugs::RESERVED_SLUGS.map(&:downcase)

    errors.add(:slug, :exclusion) if forbid.find { |w| slug.eql?(w) }
  end
end
