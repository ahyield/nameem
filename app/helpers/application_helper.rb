module ApplicationHelper
  include Pagy::Frontend

  def active?(path)
    if request.path == path
      "border-blue-500 text-gray-900"
    else
      "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
    end
  end

  def active_mobile?(path)
    if request.path == path
      "bg-indigo-50 border-indigo-500 text-indigo-700"
    else
      "border-transparent text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700"
    end
  end

  def first_paragraph(article)
    article.alternative_titles.first
  end

  def article_cover(article)
    article.article_images.first
  end

  def article_description(article)
    article.description.first
  end

  def short_date(date)
    if date.to_date.year == Time.zone.today.year
      l date.to_date, format: :short
    else
      l date.to_date, format: :long
    end
  end
end
