class UserPolicy < ApplicationPolicy
  def edit?
    user == record
  end

  def update?
    user == record
  end

  def drafts?
    user == record
  end

  def stats?
    user == record
  end

  def bookmarks?
    user == record
  end
end
