require "rails_helper"

RSpec.describe PlausibleClient::Plausible do
  let(:article) { create(:article, :published) }
  let(:client) { described_class.new(article: article) }
  let(:conn) { instance_double(Faraday::Connection) }
  let(:response) { instance_double(Faraday::Response, status: 200, body: { results: [{ metrics: [123, 45] }] }.to_json) }

  before do
    allow(Faraday).to receive(:new).and_return(conn)
    allow(conn).to receive(:post).and_return(response)
  end

  describe "#aggregate" do
    it "returns parsed metrics" do
      result = client.aggregate
      expect(result).to eq(pageviews: 123, visitors: 45)
    end

    it "returns zeros for empty results" do
      allow(response).to receive(:body).and_return({ results: [] }.to_json)

      result = client.aggregate
      expect(result).to eq(pageviews: 0, visitors: 0)
    end

    it "returns empty hash if results nil" do
      allow(response).to receive(:body).and_return({ results: nil }.to_json)

      result = client.aggregate
      expect(result).to eq({})
    end

    it "raises ArgumentError for invalid article" do
      broken_client = described_class.new(article: nil)
      expect { broken_client.aggregate }.to raise_error(ArgumentError, /Article must be provided/)
    end
  end

  describe "#handle_response" do
    it "raises AuthError for 401" do
      allow(response).to receive(:status).and_return(401)
      expect { client.send(:handle_response, response) }.to raise_error(PlausibleClient::AuthError)
    end

    it "raises NotFoundError for 404" do
      allow(response).to receive(:status).and_return(404)
      expect { client.send(:handle_response, response) }.to raise_error(PlausibleClient::NotFoundError)
    end

    it "raises ApiError for 422 with error message" do
      allow(response).to receive_messages(status: 422, body: { error: "Invalid param" }.to_json)
      expect { client.send(:handle_response, response) }.to raise_error(PlausibleClient::ApiError, /Invalid param/)
    end

    it "raises ApiError for other errors" do
      allow(response).to receive_messages(status: 500, body: "Internal Error")
      expect { client.send(:handle_response, response) }.to raise_error(PlausibleClient::ApiError, /500/)
    end
  end

  describe "#timeseries" do
    let(:timeseries_response) do
      instance_double(Faraday::Response, status: 200, body: {
        results: [
          { dimensions: ["2026-01-21"], metrics: [10, 5] },
          { dimensions: ["2026-01-22"], metrics: [20, 8] }
        ]
      }.to_json)
    end

    before { allow(conn).to receive(:post).and_return(timeseries_response) }

    it "returns parsed timeseries data" do
      result = client.timeseries
      expect(result).to eq([
        { date: "2026-01-21", pageviews: 10, visitors: 5 },
        { date: "2026-01-22", pageviews: 20, visitors: 8 }
      ])
    end

    it "returns empty array for empty results" do
      allow(timeseries_response).to receive(:body).and_return({ results: [] }.to_json)
      expect(client.timeseries).to eq([])
    end
  end
end
