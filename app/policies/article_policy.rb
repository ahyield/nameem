class ArticlePolicy < ApplicationPolicy
  def update?
    user.present? && (record.user == user || user.editor? || user.admin?)
  end

  def edit?
    update?
  end
end
