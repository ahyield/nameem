class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def about_nameem; end

  def terms; end

  def privacy; end
end
