class User < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :articles, dependent: :destroy

  has_one_attached :avatar

  normalizes :email, with: ->(email) { email.downcase.strip }

  validates :email, uniqueness: true

  has_person_name

  generates_token_for :magic_login, expires_in: 15.minutes do
    last_sign_in_at
  end

  after_validation :set_slug, on: :create

  def set_slug
    self.slug = email.split("@").first
  end
end
