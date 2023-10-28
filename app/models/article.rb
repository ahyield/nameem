class Article < ApplicationRecord
  belongs_to :user
  has_many_attached :images

  attribute :uuid, MySQLBinUUID::Type.new
end
