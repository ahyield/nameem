module Sessions
  class MagicLinksController < ApplicationController
    include Authentication::UnauthenticatedAccess
    include Authentication::ViaMagicLink

    before_action :ensure_pending_authentication_exists

    rate_limit to: 10, within: 15.minutes, only: :create, with: lambda {
      flash.now[:error] = "عدد المحاولات كبير، يرجى المحاولة لاحقًا"
      render :show, status: :too_many_requests
    }

    def show; end

    def create
      magic_link = MagicLink.consume(params[:code])

      if magic_link.nil? || magic_link.user.email != email_address_pending_authentication
        flash.now[:error] = "الرمز غير صحيح أو منتهي الصلاحية"
        return render :show, status: :unprocessable_content
      end

      cookies.delete(:pending_authentication_token)

      case magic_link.purpose
      when "sign_up"
        start_new_session_for(magic_link.user)
        redirect_to new_signups_completion_path
      when "confirm_email"
        magic_link.user.update!(confirmed: true)
        start_new_session_for(magic_link.user)
        redirect_to root_path, notice: "تم تأكيد بريدك الإلكتروني"
      else # sign_in
        start_new_session_for(magic_link.user)
        redirect_to root_path
      end
    end

    private

    def ensure_pending_authentication_exists
      redirect_to login_path if email_address_pending_authentication.blank?
    end
  end
end
