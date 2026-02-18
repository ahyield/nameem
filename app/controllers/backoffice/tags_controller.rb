module Backoffice
  class TagsController < BaseController
    def index
      @pagy, @tags = pagy(Tag.popular)
    end

    def edit
      @tag = Tag.find_by!(slug: params[:slug])
    end

    def update
      @tag = Tag.find_by!(slug: params[:slug])

      if @tag.update(tag_params)
        flash[:notice] = "تم تحديث الموضوع بنجاح"
        redirect_to backoffice_tags_path
      else
        flash[:error] = @tag.errors.full_messages.join(", ")
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @tag = Tag.find_by!(slug: params[:slug])
      @tag.destroy
      flash[:notice] = "تم حذف الموضوع بنجاح"
      redirect_to backoffice_tags_path
    end

    def merge
      @source = Tag.find_by!(slug: params[:slug])
      @target = Tag.find(params[:target_id])

      @source.article_tags.update_all(tag_id: @target.id)
      Tag.reset_counters(@target.id, :article_tags)
      @source.destroy

      flash[:notice] = "تم دمج الموضوع بنجاح"
      redirect_to backoffice_tags_path
    end

    private

    def tag_params
      params.expect(tag: [:name])
    end
  end
end
