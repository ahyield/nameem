class Article < ApplicationRecord
  include Metable

  has_many_attached :images

  belongs_to :user

  scope :published, -> { where(published: true) }
  scope :picked, -> { where(picked: true) }
  scope :featured, -> { where(featured: true) }
  scope :drafts, -> { where(published: false) }

  attribute :uuid, MySQLBinUUID::Type.new

  validates :featured, inclusion: { in: [true, false] }, allow_blank: true
  validates :published, inclusion: { in: [true, false] }, allow_blank: true
  validates :picked, inclusion: { in: [true, false] }, allow_blank: true

  after_update :create_description

  def to_param
    uuid
  end

  def publish
    update_column(:published, true)
  end

  def unpublish
    update_column(:published, false)
  end

  def draft?
    !published?
  end

  def pick
    update(picked: true)
  end

  def feature
    update(featured: true)
  end
end
