class Article < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  attribute :uuid, MySQLBinUUID::Type.new

  def to_param
    uuid
  end
end
