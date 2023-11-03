require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /about_nameem" do
    it "returns http success" do
      get "/static_pages/about_nameem"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /policy" do
    it "returns http success" do
      get "/static_pages/policy"
      expect(response).to have_http_status(:success)
    end
  end

end
