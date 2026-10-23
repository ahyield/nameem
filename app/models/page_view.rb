class PageView < ApplicationRecord
  belongs_to :viewable, polymorphic: true, counter_cache: :real_views_count

  validates :visitor_id, uniqueness: { scope: %i[viewable_type viewable_id] }
end
