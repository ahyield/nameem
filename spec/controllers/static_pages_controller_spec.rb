require "rails_helper"

RSpec.describe StaticPagesController do
  describe "GET #about_nameem" do
    it "renders the about_nameem template" do
      get :about_nameem
      expect(response).to render_template(:about_nameem)
    end

    it "returns a successful response" do
      get :about_nameem
      expect(response).to be_successful
    end
  end

  describe "GET #terms" do
    context "when in production environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }

      it "redirects to the specified article" do
        get :terms
        expect(response).to redirect_to(user_article_path(slug: "nameem", uuid: "192ed78a-66a3-4856-8977-88adeafdfaf1"))
      end
    end

    context "when not in production environment" do
      it "renders the terms template" do
        get :terms
        expect(response).to render_template(:terms)
      end

      it "returns a successful response" do
        get :terms
        expect(response).to be_successful
      end
    end
  end

  describe "GET #privacy" do
    context "when in production environment" do
      before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }

      it "redirects to the specified article" do
        get :privacy
        expect(response).to redirect_to(user_article_path(slug: "nameem", uuid: "3ae32f77-6073-4d6c-9d6d-d1d3b9e8ec80"))
      end
    end

    context "when not in production environment" do
      it "renders the privacy template" do
        get :privacy
        expect(response).to render_template(:privacy)
      end

      it "returns a successful response" do
        get :privacy
        expect(response).to be_successful
      end
    end
  end
end
