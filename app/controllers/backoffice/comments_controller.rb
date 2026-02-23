module Backoffice
  class CommentsController < BaseController
    before_action :set_comment, only: [:show, :destroy]

    def index
      @page_title = "التعليقات"
      @filter = params[:filter] || "all"

      comments = Comment.includes(:user, :article).order(created_at: :desc)
      comments = filter_comments(comments)
      comments = search_comments(comments) if params[:q].present?

      @pagy, @comments = pagy(comments)
    end

    def show
      @page_title = "تعليق ##{@comment.id}"
      @replies = @comment.replies.includes(:user).order(created_at: :asc) if @comment.parent_id.nil?
    end

    def destroy
      @comment.destroy
      flash[:notice] = "تم حذف التعليق بنجاح"
      redirect_to backoffice_comments_path
    end

    private

    def set_comment
      @comment = Comment.find(params[:id])
    end

    def filter_comments(comments)
      case @filter
      when "top_level" then comments.top_level
      when "replies"   then comments.where.not(parent_id: nil)
      else comments
      end
    end

    def search_comments(comments)
      q = "%#{params[:q]}%"
      comments.joins(:user, :article)
              .where("users.first_name LIKE :q OR users.last_name LIKE :q OR articles.title LIKE :q", q: q)
    end
  end
end
