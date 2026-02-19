class ArticlePolicy < ApplicationPolicy
  def create?
    user.present? && user.confirmed?
  end

  def update?
    user.present? && (record.user == user || user.editor? || user.admin?)
  end

  def edit?
    update?
  end

  def show?
    if record.draft?
      edit?
    else
      true
    end
  end
end
