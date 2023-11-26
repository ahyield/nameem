module Backoffice
  class UsersController < BaseController
    def index
      @pagy, @users = pagy(User.confirmed.order(created_at: :asc))
    end

    def edit
      @user = User.friendly.find(params[:slug])
    end

    def update
      @user = User.friendly.find(params[:slug])

      if @user.update(user_params)
        flash[:notice] = "تم تحديث البيانات بنجاح"
        redirect_to backoffice_users_path
      else
        flash[:alert] = @user.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:featured, :picked)
    end
  end
end
