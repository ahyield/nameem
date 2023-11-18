module Api
  class ArticlesController < ActionController::API
    include ActionController::Helpers
    include Authentication

    before_action :authenticate_user!, except: [:show]

    def show
      @user = User.find_by(slug: params[:slug])
      @article = @user.articles.find_by(uuid: params[:uuid])
      render json: @article
    end

    def new
      @article = Current.user.articles.new(uuid: SecureRandom.uuid)
      render json: @article
    end

    def edit
      @article = Article.find_by(uuid: params[:uuid])
      render json: @article
    end

    def update
      @article = Article.find_or_create_by(uuid: params[:uuid])
      @article.attributes = article_params
      @article.user = Current.user unless @article.user
      @article.save!
      render json: @article
    end

    private

    def article_params
      article_params = params[:article]
      article_params ? article_params.permit(:title, :published_at, :slug, :user_id, :uuid, content: {}) : {}
    end
  end
end
