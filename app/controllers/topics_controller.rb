class TopicsController < ApplicationController
  skip_before_action :require_authentication

  def index
    @tags = Tag.popular.with_articles
  end

  def show
    @tag = Tag.find_by!(slug: params[:slug])
  end

  def articles
    @tag = Tag.find_by!(slug: params[:slug])
    @pagy, @articles = pagy(@tag.articles.published.order(published_at: :desc))

    respond_to do |format|
      format.turbo_stream
    end
  end

  def search
    query = params[:q].to_s.strip
    tags = if query.present?
             Tag.where("name LIKE ?", "%#{Tag.sanitize_sql_like(query)}%").limit(10)
           else
             Tag.popular.limit(10)
           end
    render json: tags.pluck(:name)
  end
end
