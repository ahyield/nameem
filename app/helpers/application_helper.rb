module ApplicationHelper
  # "قراءة دقيقة", "قراءة دقيقتين", "قراءة ٥ دقائق", "قراءة ١٢ دقيقة"
  def reading_time_label(minutes)
    case minutes
    when 1 then "قراءة دقيقة"
    when 2 then "قراءة دقيقتين"
    when 3..10 then "قراءة #{minutes} دقائق"
    else "قراءة #{minutes} دقيقة"
    end
  end

  def active_nav_class(path)
    if request.path == path
      "border-blue-500 text-gray-900"
    else
      "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
    end
  end

  def active_settings_sidebar(path)
    if request.path == path
      "bg-gray-50 text-blue-600"
    else
      "text-gray-700 hover:text-blue-600 hover:bg-gray-50"
    end
  end

  def first_paragraph(article)
    article.alternative_titles.first&.truncate(86)
  end

  def article_cover(article)
    article.article_images.first
  end

  def short_date(date)
    if date.to_date.year == Time.zone.today.year
      l date.to_date, format: :short, locale: :ar
    else
      l date.to_date, format: :long, locale: :ar
    end
  end
end
