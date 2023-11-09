class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @articles = Article.published.last(6)
  end
end
