class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def about_nameem; end

  def terms
    if Rails.env.production?
      redirect_to user_article_path(slug: "nameem", uuid: "192ed78a-66a3-4856-8977-88adeafdfaf1")
    end
  end

  def privacy
    if Rails.env.production?
      redirect_to user_article_path(slug: "nameem", uuid: "3ae32f77-6073-4d6c-9d6d-d1d3b9e8ec80")
    end
  end
end
