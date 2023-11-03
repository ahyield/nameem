class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def edit; end
end
