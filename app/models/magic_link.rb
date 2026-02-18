class MagicLink < ApplicationRecord
  belongs_to :user

  enum :purpose, { sign_in: 0, sign_up: 1, confirm_email: 2 }

  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :stale, -> { where(expires_at: ..Time.current) }

  before_validation :set_code, on: :create
  before_validation :set_expires_at, on: :create

  def self.consume(code)
    sanitized = Code.sanitize(code.to_s)
    link = active.find_by(code: sanitized)
    return nil unless link

    link.destroy
    link
  end

  private

  def set_code
    self.code = Code.generate
  end

  def set_expires_at
    self.expires_at ||= 15.minutes.from_now
  end
end
