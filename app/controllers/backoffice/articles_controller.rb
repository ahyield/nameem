module Backoffice
  class ArticlesController < BaseController
    def index
      @pagy, @articles = pagy(Article.published.order(created_at: :asc))
    end

    def edit
      @user = User.find_by(slug: params[:user_slug])
      @article = @user.articles.find_by(uuid: params[:uuid])
    end

    def update
      @user = User.find_by(slug: params[:user_slug])
      @article = @user.articles.find_by(uuid: params[:uuid])

      if @article.update(article_params)
        flash[:notice] = "تم تحديث البيانات بنجاح"
        redirect_to backoffice_articles_path
      else
        flash[:error] = "حدث خطأ أثناء تحديث البيانات"
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def article_params
      params.require(:article).permit(:picked, :featured)
    end
  end
end
