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
                   format:      { with:    /\A[a-zA-Z0-9_-]+\z/,
                                  message: "إسم المستخدم يجب أن يكون أحرف مع أرقام، شرطة، أو شرطة سفلية فقط" }
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
