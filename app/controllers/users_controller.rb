class UsersController < ApplicationController
  skip_before_action :require_authentication, only: %i[show articles article]
  before_action :resume_session, only: %i[show articles article]

  def show
    @user = User.friendly.find(params[:slug])
  end

  def article
    @user = User.friendly.find(params[:slug])
    @article = @user.articles.find_by(uuid: params[:uuid])

    authorize @article, :show?

    @liked = Current.user&.article_likes&.exists?(article: @article)
    @comments = @article.comments.includes(:user, :rich_text_body).order(created_at: :asc)

    respond_to do |format|
      format.html
      format.json { render json: @article }
    end
  end

  def articles
    @user = User.friendly.find(params[:slug])
    @pagy, @articles = pagy(@user.articles.published.order(published_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def drafts
    @user = User.friendly.find(params[:slug])
    @pagy, @articles = pagy(@user.articles.drafts.order(updated_at: :desc))

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def destroy
    @user = User.friendly.find(params[:slug])
    @article = @user.articles.find_by(uuid: params[:uuid])

    @article.destroy

    redirect_to user_path(@user)
  end
end
