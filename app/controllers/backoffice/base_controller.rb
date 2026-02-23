module Backoffice
  class BaseController < ApplicationController
    layout "backoffice"

    before_action :authenticate_admin!
    before_action :set_page_title

    def authenticate_admin!
      unless user_signed_in? && (current_user.editor? || current_user.admin?)
        flash[:error] = "غير مسموح لك بالدخول إلى هذه الصفحة"
        redirect_to "/"
      end
    end

    private

    def require_admin!
      unless current_user.admin?
        flash[:error] = "هذا الإجراء مسموح للمدراء فقط"
        redirect_to backoffice_root_path
      end
    end

    def set_page_title
      @page_title = "لوحة التحكم"
    end
  end
end
