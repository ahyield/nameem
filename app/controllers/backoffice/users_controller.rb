module Backoffice
  class UsersController < BaseController
    EDITOR_ROLES = %w[featured picked confirmed].freeze
    ADMIN_ROLES = %w[admin editor].freeze

    before_action :set_user, only: [:show, :update, :destroy, :toggle_role]
    before_action :require_admin!, only: [:destroy]

    def index
      @page_title = "المستخدمين"
      @filter = params[:filter] || "all"

      users = User.select("users.*, (SELECT COUNT(*) FROM articles WHERE articles.user_id = users.id) AS articles_total")
                  .with_attached_avatar
                  .order(created_at: :desc)
      users = filter_users(users)
      users = search_users(users) if params[:q].present?

      @pagy, @users = pagy(users)
    end

    def show
      @page_title = @user.name
      @recent_articles = @user.articles.order(created_at: :desc).limit(5)
    end

    def update
      permitted = EDITOR_ROLES.map(&:to_sym)
      permitted += ADMIN_ROLES.map(&:to_sym) if current_user.admin?

      if @user.update(params.expect(user: permitted))
        flash[:notice] = "تم تحديث البيانات بنجاح"
      else
        flash[:error] = @user.errors.full_messages.join("، ")
      end
      redirect_to backoffice_user_path(@user)
    end

    def destroy
      @user.destroy
      flash[:notice] = "تم حذف المستخدم بنجاح"
      redirect_to backoffice_users_path
    end

    def toggle_role
      allowed_roles = current_user.admin? ? EDITOR_ROLES + ADMIN_ROLES : EDITOR_ROLES
      # Pick the role from our own list, so request data never names an attribute directly
      role = allowed_roles.find { |allowed| allowed == params[:role] }

      if role
        @user.update!(role => !@user[role])
      else
        flash[:error] = "غير مسموح بتعديل هذا الدور"
      end
      redirect_to backoffice_user_path(@user)
    end

    private

    def set_user
      @user = User.friendly.find(params[:slug])
    end

    def filter_users(users)
      case @filter
      when "confirmed"   then users.confirmed
      when "unconfirmed" then users.where(confirmed: false)
      when "featured"    then users.featured
      when "picked"      then users.picked
      when "admins"      then users.admins
      when "editors"     then users.editors
      else users
      end
    end

    def search_users(users)
      q = "%#{params[:q]}%"
      users.where("first_name LIKE :q OR last_name LIKE :q OR email LIKE :q OR slug LIKE :q", q: q)
    end
  end
end
