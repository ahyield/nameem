require "rails_helper"

RSpec.describe FeedController do
  let(:user) { create(:user) }

  before do
    create_list(:article, 10, :published, user:)
    create_list(:article, 5, :picked, user:)
    create_list(:article, 5, :featured, user:)
    create_list(:user, 6, :picked)

    sign_in user
  end

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "assigns the most recently published articles to @articles" do
      get :index
      expected_articles = Article.published.order(published_at: :desc).limit(20)
      expect(assigns(:articles)).to match_array(expected_articles)
    end

    it "assigns a sample of 4 picked users to @users" do
      get :index
      expect(assigns(:users).size).to eq(4)
      expect(assigns(:users)).to all(be_an(User))
    end
  end

  describe "GET #latest_feed" do
    it "returns a successful response in Turbo Stream format" do
      get :latest_feed, format: :turbo_stream
      expect(response).to be_successful
    end

    it "assigns the most recently published articles to @articles" do
      get :latest_feed, format: :turbo_stream
      expected_articles = Article.published.order(published_at: :desc).limit(20)
      expect(assigns(:articles)).to match_array(expected_articles)
    end
  end

  describe "GET #picked_feed" do
    it "returns a successful response in Turbo Stream format" do
      get :picked_feed, format: :turbo_stream
      expect(response).to be_successful
    end

    it "assigns the most recently picked articles to @articles" do
      get :picked_feed, format: :turbo_stream
      expected_articles = Article.picked.order(published_at: :desc).limit(20)
      expect(assigns(:articles)).to match_array(expected_articles)
    end
  end

  describe "GET #popular_feed" do
    it "returns a successful response in Turbo Stream format" do
      get :popular_feed, format: :turbo_stream
      expect(response).to be_successful
    end

    it "assigns the most viewed articles @articles" do
      get :popular_feed, format: :turbo_stream
      expected_articles = Article.most_popular
      expect(assigns(:articles)).to match_array(expected_articles)
    end
  end
end
