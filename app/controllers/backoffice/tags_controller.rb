module Backoffice
  class TagsController < BaseController
    before_action :set_tag, only: [:show, :edit, :update, :destroy, :merge]

    def index
      @page_title = "المواضيع"

      tags = Tag.popular
      tags = search_tags(tags) if params[:q].present?

      @pagy, @tags = pagy(tags)
    end

    def show
      @page_title = @tag.name
      @pagy, @articles = pagy(@tag.articles.published.includes(:user).order(created_at: :desc))
    end

    def edit
      @page_title = "تعديل: #{@tag.name}"
      @other_tags = Tag.where.not(id: @tag.id).popular.limit(50)
    end

    def update
      if @tag.update(tag_params)
        flash[:notice] = "تم تحديث الموضوع بنجاح"
        redirect_to backoffice_tag_path(@tag)
      else
        flash[:error] = @tag.errors.full_messages.join("، ")
        @other_tags = Tag.where.not(id: @tag.id).popular.limit(50)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @tag.destroy
      flash[:notice] = "تم حذف الموضوع بنجاح"
      redirect_to backoffice_tags_path
    end

    def merge
      @target = Tag.find(params[:target_id])

      @tag.article_tags.update_all(tag_id: @target.id)
      Tag.reset_counters(@target.id, :article_tags)
      @tag.destroy

      flash[:notice] = "تم دمج الموضوع بنجاح إلى \"#{@target.name}\""
      redirect_to backoffice_tag_path(@target)
    end

    private

    def set_tag
      @tag = Tag.find_by!(slug: params[:slug])
    end

    def tag_params
      params.expect(tag: [:name])
    end

    def search_tags(tags)
      q = "%#{params[:q]}%"
      tags.where("name LIKE :q OR slug LIKE :q", q: q)
    end
  end
end
