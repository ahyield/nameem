module CoverImageHelper
  # An absolute URL to the article's first image, cropped on the server to size ([width, height], at 2x for
  # sharp screens). Cropping here rather than with CSS keeps pages light and works in email clients, which
  # ignore object-fit.
  def cover_image_url(article, size)
    blob = cover_image_blob(article)
    return unless blob&.variable?

    rails_representation_url(blob.variant(resize_to_fill: size))
  end

  # Editor uploads live in the article body as Active Storage URLs rather than as attachments,
  # so fall back to the blob behind the first image in content_html
  def cover_image_blob(article)
    article.images.first&.blob || blob_from_url(article.article_images.first)
  end

  def blob_from_url(url)
    signed_id = url.to_s[%r{/rails/active_storage/blobs/(?:proxy|redirect)/([^/]+)/}, 1]
    ActiveStorage::Blob.find_signed(signed_id) if signed_id
  end
end
