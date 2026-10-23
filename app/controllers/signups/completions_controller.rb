module Signups
  class CompletionsController < ApplicationController
    def new
      @user = current_user
    end

    def create
      @user = current_user
      @user.attributes = user_params
      @user.confirmed = true unless @user.name.blank? || @user.slug.blank?

      if @user.save
        redirect_to root_path
      else
        flash.now[:error] = @user.errors.full_messages.to_sentence
        @user.avatar = nil
        render :new, status: :unprocessable_content
      end
    end

    private

    def user_params
      params.expect(user: %i[name avatar slug])
    end
  end
end
