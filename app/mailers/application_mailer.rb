class ApplicationMailer < ActionMailer::Base
  default from: "noreply@nameem.com"
  layout "mailer"

  before_action :attach_logo

  private

  def attach_logo
    attachments.inline["logo.png"] = Rails.root.join("app/assets/images/brand/logo.png").read
  end
end
