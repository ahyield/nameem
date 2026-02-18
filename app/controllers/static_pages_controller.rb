class StaticPagesController < ApplicationController
  skip_before_action :require_authentication
  before_action :resume_session

  def about_nameem; end

  def terms
    redirect_to user_article_path(slug: "nameem", uuid: "192ed78a-66a3-4856-8977-88adeafdfaf1") if Rails.env.production?
  end

  def privacy
    redirect_to user_article_path(slug: "nameem", uuid: "3ae32f77-6073-4d6c-9d6d-d1d3b9e8ec80") if Rails.env.production?
  end
end
