class ArticlePolicy < ApplicationPolicy
  def update?
    user.present? && (record.user == user || user.editor? || user.admin?)
  end

  def edit?
    update?
  end

  def show?
    if record.draft?
      user.present? && record.user == user
    else
      true
    end
  end
end
