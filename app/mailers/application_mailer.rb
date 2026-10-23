class ApplicationMailer < ActionMailer::Base
  default from: "نميم <noreply@nameem.com>", reply_to: "support@nameem.com"
  layout "mailer"

  before_action :attach_logo

  # The record an email was about was deleted before the delivery job ran; there's nothing to send
  rescue_from ActiveJob::DeserializationError, with: -> {}

  private

  # Sends to a user under an email category (see Email::Categories). Mail the user switched off, or mail to
  # a suppressed address, isn't delivered. Everything but account mail carries one-click unsubscribe.
  def mail_user(user, category:, subject:, to: user.email, **)
    @email_category = category.to_s
    # Set before mail() renders the template, so the footer can link to it
    if @email_category != "account"
      token = user.unsubscribe_token(category)
      @unsubscribe_url = email_unsubscribe_url(token:)
      headers["List-Unsubscribe"] = "<#{email_one_click_unsubscribe_url(token:)}>"
      headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
    end

    mail(to:, subject:, **).tap do |message|
      message.perform_deliveries = user.emailable?(category)
    end
  end

  def attach_logo
    attachments.inline["logo.png"] = Rails.root.join("app/assets/images/brand/logo.png").read
  end
end
