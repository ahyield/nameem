module ApplicationHelper
  def active?(path)
    if request.path == path
      "border-blue-500 text-gray-900"
    else
      "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
    end
  end
end
