module Authentication
  module ViaMagicLink
    extend ActiveSupport::Concern

    private

    def redirect_to_magic_link_verification(magic_link)
      write_pending_authentication_cookie(magic_link.user.email)
      redirect_to session_magic_link_path
    end

    def redirect_to_fake_magic_link_verification(email)
      write_pending_authentication_cookie(email)
      redirect_to session_magic_link_path
    end

    def email_address_pending_authentication
      cookies.signed[:pending_authentication_token]
    end

    def write_pending_authentication_cookie(email)
      cookies.signed[:pending_authentication_token] = {
        value:     email,
        expires:   30.minutes.from_now,
        httponly:  true,
        same_site: :lax
      }
    end
  end
end
