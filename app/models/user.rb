class User < ApplicationRecord
  extend FriendlyId
  friendly_id :email, use: :slugged

  has_many :articles, dependent: :destroy

  has_one_attached :avatar

  has_person_name

  normalizes :email, with: ->(email) { email.downcase.strip }

  validates :email, uniqueness: true
  validates :slug, uniqueness: true, presence: true, allow_blank: false

  generates_token_for :magic_login, expires_in: 15.minutes do
    last_sign_in_at
  end
end
