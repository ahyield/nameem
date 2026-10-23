# Emails are written with a small set of classes in the mailer layout; premailer inlines them
# (Gmail and Outlook drop <style> blocks) and builds the plain-text part from the HTML.
Premailer::Rails.config.merge!(
  generate_text_part: true,
  remove_ids:         false,
  adapter:            :nokogiri
)
