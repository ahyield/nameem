class Article < ApplicationRecord
  has_many_attached :images

  belongs_to :user

  scope :published, -> { where(published: true) }
  scope :picked, -> { where(picked: true) }
  scope :featured, -> { where(featured: true) }

  attribute :uuid, MySQLBinUUID::Type.new

  def to_param
    uuid
  end
end
