class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[show user_articles]

  def show
    @user = User.friendly.find(params[:slug])
  end

  def user_articles
    user = User.friendly.find(params[:slug])
    @pagy, @articles = pagy(user.articles.published.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new; end

  def edit
    @user = current_user
  end

  def update; end
end
