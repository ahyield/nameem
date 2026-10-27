module CoverImageHelper
  # An absolute URL to the article's first image, cropped on the server to size ([width, height], at 2x for
  # sharp screens). Cropping here rather than with CSS keeps pages light and works in email clients, which
  # ignore object-fit. The crop keeps the busiest part of the image (a banner's logo and words) rather than
  # its middle.
  def cover_image_url(article, size)
    blob = cover_image_blob(article)
    return unless blob&.variable?

    rails_representation_url(blob.variant(resize_to_fill: size + [{ crop: :attention }]))
  end

  # For pages: the cropped cover, or the original image when it can't be cropped (an external link)
  def card_cover_url(article, size)
    cover_image_url(article, size) || article_cover(article)
  end

  # One of the article's images cropped to size, for choosing the cover; the image itself when it can't be
  def cropped_image_url(src, size)
    blob = blob_from_url(src)
    blob&.variable? ? rails_representation_url(blob.variant(resize_to_fill: size + [{ crop: :attention }])) : src
  end

  # Editor uploads live in the article body as Active Storage URLs rather than as attachments, so the cover
  # the author chose (or the first image in content_html) is found by its URL. Older articles may have
  # attached images instead.
  def cover_image_blob(article)
    (blob_from_url(article.cover_image_src) if article.cover_image_src.present?) ||
      article.images.first&.blob || blob_from_url(article.cover_image)
  end

  def blob_from_url(url)
    signed_id = url.to_s[%r{/rails/active_storage/blobs/(?:proxy|redirect)/([^/]+)/}, 1]
    ActiveStorage::Blob.find_signed(signed_id) if signed_id
  end
end
