class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def edit
    @article = Article.find_by(uuid: params[:uuid])

    respond_to do |format|
      format.html
      format.json { render json: @article }
    end
  end

  def update
    @article = Article.find_by(uuid: params[:uuid])
    @article.published    = params[:publish] == true ? @article.publish : @article.draft
    @article.published_at = DateTime.now if @article.published_at.nil? && @article.published?
    @article.save!

    redirect_to user_article_path(uuid: @article.uuid, slug: Current.user.slug)
  end

  def show_modal
    @article = Article.find_by(uuid: params[:uuid])
  end
end
