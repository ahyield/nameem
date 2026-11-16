# The author's actions on an article, wherever its menu shows them
module ArticleActionsHelper
  # Data for the delete button: asks in the confirm dialog (app/javascript/lib/confirm_dialog.js) before
  # anything is removed
  def delete_article_data(article)
    what = article.published? ? "هذا الموضوع" : "هذه المسودة"
    { turbo_confirm: "هل أنت متأكد من حذف #{what}؟ لا يمكن التراجع عن ذلك.", confirm_label: "حذف",
      confirm_destructive: true }
  end
end
