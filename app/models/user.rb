class User < ApplicationRecord
  has_many :articles, dependent: :destroy

  normalizes :email, with: ->(email) { email.downcase.strip }

  generates_token_for :magic_login, expires_in: 15.minutes do
    last_sign_in_at
  end
end
