class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new
    redirect_to settings_security_path unless current_user&.confirmed?
  end

  def edit
    @user = User.find_by(slug: params[:slug])
    @article = @user.articles.find_by(uuid: params[:uuid])
    authorize @article, :edit?

    respond_to do |format|
      format.html
      format.json { render json: @article }
    end
  end

  def update
    @user = User.find_by(slug: params[:slug])

    @article = @user.articles.find_by(uuid: params[:uuid])
    authorize @article, :update?

    @article.published = params[:publish]
    @article.published_at = DateTime.now if @article.published_at.nil? && @article.published?
    @article.save!

    redirect_to user_article_path(uuid: @article.uuid, slug: Current.user.slug)
  end

  def show_modal
    @article = Article.find_by(uuid: params[:uuid])
  end
end
