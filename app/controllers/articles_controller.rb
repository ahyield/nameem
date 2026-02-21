class ArticlesController < ApplicationController
  # require_authentication is inherited from ApplicationController

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

    @article.description = params[:description].presence if params.key?(:description)
    @article.published = params[:publish]
    @article.published_at = DateTime.now if @article.published_at.nil? && @article.published?
    @article.save!

    sync_tags(@article, params[:tag_names])

    redirect_to user_article_path(uuid: @article.uuid, slug: @user.slug)
  end

  def show_modal
    @user = User.find_by(slug: params[:slug])

    @article = @user.articles.find_by(uuid: params[:uuid])
  end

  private

  def sync_tags(article, tag_names)
    tag_names = Array(tag_names).map(&:strip).compact_blank.first(5)
    tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }
    article.tags = tags
  end
end
