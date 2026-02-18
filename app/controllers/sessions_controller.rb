class SessionsController < ApplicationController
  include Authentication::UnauthenticatedAccess
  include Authentication::ViaMagicLink

  before_action :redirect_authenticated_user, only: [:new]

  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    flash[:error] = "عدد المحاولات كبير، يرجى المحاولة لاحقًا"
    redirect_to login_path
  }

  def new; end

  def create
    user = User.find_by(email: login_params[:email])

    if user&.confirmed?
      magic_link = user.send_magic_link(purpose: :sign_in)
      redirect_to_magic_link_verification(magic_link)
    else
      redirect_to_fake_magic_link_verification(login_params[:email])
    end
  end

  def destroy
    terminate_session
    redirect_to root_path
  end

  private

  def login_params
    params[:login]
  end
end
