class ArticlesController < ApplicationController
  # require_authentication is inherited from ApplicationController
  before_action :refuse_suspended_user, only: :update

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
    @article.comments_enabled = params[:comments_enabled] == "1" if params.key?(:comments_enabled)
    @article.assign_attributes(seo_params)
    @article.published = params[:publish]
    @article.published_at = DateTime.now if @article.published_at.nil? && @article.published?

    if @article.save
      sync_tags(@article, params[:tag_names])
      redirect_to helpers.article_link(@article)
    else
      render :show_modal, status: :unprocessable_content
    end
  end

  def show_modal
    @user = User.friendly.find(params[:slug])
    @article = @user.articles.find_by!(uuid: params[:uuid])
    authorize @article, :edit?
  end

  private

  # The publish dialog's advanced section. A blank slug goes back to following the title.
  def seo_params
    seo = params.fetch(:seo, {}).permit(:title, :slug, :canonical_url, :noindex, :cover_image_src)
    attributes = seo.slice(:canonical_url).to_h
    attributes[:seo_title] = seo[:title] if seo.key?(:title)
    attributes[:slug] = Article.slug_from(seo[:slug]) if seo.key?(:slug)
    attributes[:noindex] = seo[:noindex] == "1" if seo.key?(:noindex)
    attributes[:cover_image_src] = seo[:cover_image_src].presence if seo.key?(:cover_image_src)
    attributes
  end

  def sync_tags(article, tag_names)
    tag_names = Array(tag_names).map(&:strip).compact_blank.first(5)
    tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }
    article.tags = tags
  end
end
