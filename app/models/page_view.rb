class PageView < ApplicationRecord
  belongs_to :viewable, polymorphic: true, counter_cache: :real_views_count
  belongs_to :user, optional: true # the signed-in reader, when known

  validates :visitor_id, uniqueness: { scope: %i[viewable_type viewable_id] }
end
