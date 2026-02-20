require "rails_helper"

RSpec.describe HomeController do
  let(:user) { create(:user) }
  let(:picked_articles_count) { 10 }
  let(:published_articles_count) { 20 }
  let(:featured_users_count) { 6 }

  describe "GET #index" do
    before do
      create_list(:article, picked_articles_count, :picked, user:)
      create_list(:article, published_articles_count, :published, user:)
      create_list(:user, featured_users_count, :featured)
    end

    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "assigns a sample of 6 picked articles to @picked" do
      get :index
      expect(assigns(:picked).size).to eq(6)
      expect(assigns(:picked)).to all(be_an(Article))
      expect(assigns(:picked).map(&:picked).uniq).to eq([true])
    end

    it "assigns the most recently published articles to @articles" do
      get :index
      expected_articles = Article.published.order(published_at: :desc).limit(20)
      expect(assigns(:articles)).to match_array(expected_articles)
    end

    it "assigns up to 12 featured users to @users" do
      get :index
      expect(assigns(:users).size).to eq(featured_users_count)
      expect(assigns(:users)).to all(be_an(User))
      expect(assigns(:users).map(&:featured).uniq).to eq([true])
    end
  end

  describe "GET #published_articles" do
    it "renders the published_articles template in HTML format" do
      get :published_articles, format: :turbo_stream
      expect(response).to render_template(:published_articles)
    end

    it "returns a successful response in Turbo Stream format" do
      get :published_articles, format: :turbo_stream
      expect(response).to be_successful
    end

    it "assigns the most recently published articles to @articles" do
      get :published_articles, format: :turbo_stream
      expected_articles = Article.published.order(published_at: :desc).limit(20)
      expect(assigns(:articles)).to match_array(expected_articles)
    end
  end
end
