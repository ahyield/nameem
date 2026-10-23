class FollowsController < ApplicationController
  def create
    @followable = find_followable
    @follow = Current.user.follows_as_follower.create(followable: @followable)
    @following = @follow.persisted?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: root_path }
    end
  end

  def destroy
    @followable = find_followable
    Current.user.follows_as_follower.find_by(followable: @followable)&.destroy
    @followable.reload
    @following = false

    respond_to do |format|
      format.turbo_stream { render :create }
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private

  def find_followable
    if params[:followable_type] == "Tag"
      Tag.find_by!(slug: params[:slug])
    else
      User.friendly.find(params[:slug])
    end
  end
end
