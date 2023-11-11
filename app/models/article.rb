class Article < ApplicationRecord
  has_many_attached :images

  belongs_to :user

  scope :published, -> { where(published: true) }
  scope :picked, -> { where(picked: true) }
  scope :featured, -> { where(featured: true) }

  attribute :uuid, MySQLBinUUID::Type.new

  validates :featured, inclusion: { in: [true, false] }, allow_blank: true
  validates :published, inclusion: { in: [true, false] }, allow_blank: true
  validates :picked, inclusion: { in: [true, false] }, allow_blank: true

  def to_param
    uuid
  end

  def alternative_titles
    ops = content.fetch("ops")
    titles = []

    ops.each do |element|
      titles << element.fetch("insert") if element.fetch("insert").is_a?(String) && element.fetch("insert").size >= 5
    end

    titles
  end

  def article_images
    ops = content.fetch("ops")
    urls = []

    ops.each do |element|
      if element.fetch("insert").include?("customImage") && element.fetch("insert").key?("customImage")
        urls << element.fetch("insert").fetch("customImage").fetch("url")
      end
    end

    urls
  end

  # a method to get some paragraphs from the article
  # to be used as a description
  def description
    ops = content.fetch("ops")
    paragraphs = []

    ops.each do |element|
      paragraphs << element.fetch("insert") if element.fetch("insert").is_a?(String) &&
        element.fetch("insert").size >= 20
    end

    paragraphs
  end
end
