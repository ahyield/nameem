module Backoffice
  class BaseController < ApplicationController
    before_action :authenticate_admin!

    def authenticate_admin!
      unless user_signed_in? && current_user.editor?
        flash[:error] = "غير مسموح لك بالدخول إلى هذه الصفحة"
        redirect_to "/"
      end
    end
  end
end
