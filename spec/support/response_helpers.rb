module ResponseHelpers
  # Parsed JSON body of the last response
  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ResponseHelpers, type: :request
  config.include ResponseHelpers, type: :controller
end
