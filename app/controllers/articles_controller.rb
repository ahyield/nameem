class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def show
    @article = Article.find_by(uuid: params[:uuid])
  end

  def new; end

  def edit; end

  def update
    @article = Article.find_by(uuid: params[:uuid])
    @article.published    = true
    @article.published_at = DateTime.now if @article.published_at.nil?
    @article.save!

    redirect_to article_path(uuid: @article.uuid)
  end
end
