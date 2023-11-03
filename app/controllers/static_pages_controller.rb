class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!

  def about_nameem
  end

  def policy
  end
end
