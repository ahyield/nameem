require "rails_helper"

RSpec.describe "Theme" do
  let(:user) { create(:user) }

  def html_tag
    response.body[/<html[^>]*>/]
  end

  describe "PATCH /theme" do
    it "remembers a signed-out reader's choice in a cookie" do
      patch theme_path, params: { theme: "dark" }, as: :json

      expect(response).to have_http_status(:no_content)
      expect(cookies[:theme]).to eq("dark")
    end

    it "saves a signed-in reader's choice on their account" do
      sign_in(user)

      patch theme_path, params: { theme: "light" }, as: :json

      expect(user.reload.theme).to eq("light")
      expect(cookies[:theme]).to eq("light")
    end

    it "ignores anything that isn't a theme" do
      sign_in(user)

      patch theme_path, params: { theme: "neon" }, as: :json

      expect(user.reload.theme).to eq("system")
      expect(cookies[:theme]).to be_blank
    end

    it "goes back to the page without JavaScript" do
      patch theme_path, params: { theme: "dark" }, headers: { "HTTP_REFERER" => "/about-nameem" }

      expect(response).to redirect_to("/about-nameem")
    end
  end

  describe "the page" do
    it "follows the device until the reader chooses" do
      get "/about-nameem"

      expect(html_tag).to include('data-theme="system"')
      expect(html_tag).not_to include('class="dark"')
    end

    it "renders dark straight away for a reader who chose it" do
      cookies[:theme] = "dark"

      get "/about-nameem"

      expect(html_tag).to include('data-theme="dark"').and include('class="dark"')
    end

    it "prefers the account's choice to the browser's" do
      user.update!(theme: "dark")
      cookies[:theme] = "light"
      sign_in(user)

      get user_path(user)

      expect(html_tag).to include('data-theme="dark"')
    end

    it "falls back to the device for an unknown cookie" do
      cookies[:theme] = "neon"

      get "/about-nameem"

      expect(html_tag).to include('data-theme="system"')
    end
  end
end
