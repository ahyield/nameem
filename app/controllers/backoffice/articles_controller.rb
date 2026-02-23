module Backoffice
  class ArticlesController < BaseController
    before_action :set_article, only: [:show, :edit, :update, :destroy]

    def index
      @page_title = "المقالات"
      @filter = params[:filter] || "all"

      articles = Article.includes(:user).order(created_at: :desc)
      articles = filter_articles(articles)
      articles = search_articles(articles) if params[:q].present?

      @pagy, @articles = pagy(articles)
    end

    def show
      @page_title = @article.title.presence || @article.uuid
    end

    def edit
      @page_title = "تعديل: #{@article.title.presence || @article.uuid}"
    end

    def update
      if @article.update(article_params)
        flash[:notice] = "تم تحديث المقال بنجاح"
        redirect_to backoffice_article_path(@article)
      else
        flash[:error] = "حدث خطأ أثناء تحديث البيانات"
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @article.destroy
      flash[:notice] = "تم حذف المقال بنجاح"
      redirect_to backoffice_articles_path
    end

    private

    def set_article
      @article = Article.find_by!(uuid: params[:uuid])
    end

    def article_params
      params.expect(article: [:picked, :featured, :published])
    end

    def filter_articles(articles)
      case @filter
      when "published" then articles.published
      when "drafts"    then articles.drafts
      when "featured"  then articles.featured
      when "picked"    then articles.picked
      else articles
      end
    end

    def search_articles(articles)
      q = "%#{params[:q]}%"
      articles.where("title LIKE :q OR description LIKE :q", q: q)
    end
  end
end
