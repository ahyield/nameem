# Which emails a user receives, and the signed tokens that let them unsubscribe without signing in
module EmailPreferences
  extend ActiveSupport::Concern

  class_methods do
    # Returns [user, category] for a valid token, or nil
    def from_unsubscribe_token(token)
      user_id, category = Email::Categories.verifier.verified(token, purpose: :unsubscribe)
      user = find_by(id: user_id)
      [user, category] if user && Email::Categories::OPTIONAL.include?(category)
    end
  end

  # Account mail (sign-in codes, security notices) always goes out; everything else needs a confirmed,
  # unsuppressed address and the category switched on
  def emailable?(category)
    return email.present? if category.to_s == "account"
    return false if email_suppressed? || !confirmed?

    column = Email::Categories.column(category)
    column.present? && self[column]
  end

  def email_suppressed?
    email_suppressed_at.present?
  end

  def suppress_email!(reason)
    update!(email_suppressed_at: Time.current, email_suppression_reason: reason)
  end

  def unsuppress_email!
    update!(email_suppressed_at: nil, email_suppression_reason: nil)
  end

  def unsubscribe_from!(category)
    update!(Email::Categories.column(category) => false)
  end

  def unsubscribe_token(category)
    Email::Categories.verifier.generate([id, category.to_s], purpose: :unsubscribe)
  end
end
