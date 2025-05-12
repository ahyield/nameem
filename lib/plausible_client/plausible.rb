require "faraday"
require "json"

module PlausibleClient
  class Error < StandardError; end
  class AuthError < Error; end
  class NotFoundError < Error; end
  class ApiError < Error; end

  class Plausible
    attr_reader :site_id

    def initialize(article: nil, site_id: ENV.fetch("PLAUSIBLE_SITE_ID", "nameem.com"))
      @article = article
      @site_id = site_id
      @conn = Faraday.new(url: "https://plausible.io") do |faraday|
        faraday.request :json
        faraday.request :authorization, "Bearer", ENV.fetch("PLAUSIBLE_API_KEY")
        faraday.response :logger, Rails.logger, { headers: false, bodies: false } if defined?(Rails) && Rails.env.development?
        faraday.adapter Faraday.default_adapter
      end
    end

    def aggregate(metrics: %w[pageviews visitors], date_range: "all", filters: nil)
      filters ||= article_filters if @article

      params = {
        site_id:    @site_id,
        metrics:    metrics,
        date_range: date_range
      }

      params[:filters] = filters if filters

      log_request(params)
      response = @conn.post("/api/v2/query", params.transform_keys(&:to_s))
      body = handle_response(response)
      build_response(body, metrics)
    end

    def timeseries(period: "30d", metrics: %w[pageviews visitors], filters: nil)
      filters ||= article_filters if @article

      params = {
        site_id: @site_id,
        metrics: metrics,
        period:  period
      }

      params[:filters] = filters if filters

      log_request(params)
      response = @conn.post("/api/v2/timeseries", params.transform_keys(&:to_s))
      handle_response(response)
    end

    private

    def article_filters
      raise ArgumentError.new("Article must be provided") unless @article&.user && @article.uuid

      path = "/#{@article.user.slug}/#{@article.uuid}"
      [["is", "event:page", [path]]]
    rescue NoMethodError => e
      raise ArgumentError.new("Invalid article provided: #{e.message}")
    end

    def log_request(params)
      return unless defined?(Rails)

      Rails.logger.info "Plausible API request: #{params.transform_keys(&:to_s).to_json}"
    end

    def build_response(response, metrics)
      return {} if response["results"].nil?
      return metrics.to_h { |m| [m.to_sym, 0] } if response["results"].empty?

      # Map metric names to their values from the results
      metrics.each_with_index.to_h do |metric, idx|
        [metric.to_sym, response.dig("results", 0, "metrics", idx) || 0]
      end
    end

    def handle_response(response)
      case response.status
      when 200
        JSON.parse(response.body)
      when 401, 403
        raise AuthError.new("Authentication failed. Check your API key.")
      when 404
        raise NotFoundError.new("Resource not found. Check the site_id or URL parameters.")
      when 422
        error_message = begin
          JSON.parse(response.body)["error"]
        rescue StandardError
          "Invalid request parameters"
        end
        raise ApiError.new("Invalid request: #{error_message}")
      else
        raise ApiError.new("API request failed with status #{response.status}: #{response.body}")
      end
    end
  end
end
