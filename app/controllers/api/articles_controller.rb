class Api::ArticlesController < ActionController::API
  def new
    @article = Article.new(uuid: SecureRandom.uuid)
    render json: @article
  end

  def update
    @article = Article.find_or_create_by(uuid: params[:uuid])
    # @article.attributes = article_params
  end

  private

  def article_params
    article_params = params[:article]
    article_params ? article_params.permit(:title, :published_at, :slug, :user_id, :uuid, content: {}) : {}
  end
end
