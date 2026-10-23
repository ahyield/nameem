module Api
  class ArticlesController < ApiBaseController
    skip_before_action :require_authentication, only: [:show]
    before_action :refuse_suspended_user, only: %i[create update]

    def show
      @user = User.find_by!(slug: params[:slug])
      @article = @user.articles.find_by!(uuid: params[:uuid])
      render json: @article.as_json(only: %i[uuid title content content_html description published])
    end

    def edit
      @article = Article.find_by!(uuid: params[:uuid])
      authorize @article, :edit?
      render json: @article
    end

    def create
      authorize Article, :create?
      @article = Current.user.articles.new(uuid: SecureRandom.uuid)
      @article.save!
      render json: { article: @article, user: Current.user }
    end

    def update
      @article = Article.find_by!(uuid: params[:uuid])
      authorize @article, :update?
      @article.update!(article_params)
      render json: @article
    end

    private

    def article_params
      return {} unless params[:article]

      # content is free-form Lexical JSON, permitted whole below
      permitted = params[:article].except(:content).permit(:title, :content_html)
      permitted[:content] = params[:article][:content].permit!.to_h if params[:article][:content].present?
      permitted
    end
  end
end
