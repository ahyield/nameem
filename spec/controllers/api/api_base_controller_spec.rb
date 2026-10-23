require "rails_helper"

RSpec.describe Api::ApiBaseController do
  controller(described_class) do
    skip_before_action :require_authentication

    def index
      record = Article.new
      record.errors.add(:title, "is invalid")
      raise ActiveRecord::RecordInvalid.new(record)
    end
  end

  it "answers invalid records with a JSON 422" do
    get :index

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body["error"]).to include("is invalid")
  end
end
