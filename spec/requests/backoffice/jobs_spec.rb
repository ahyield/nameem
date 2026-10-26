require "rails_helper"

RSpec.describe "Mission Control" do
  it "opens for a signed-in admin" do
    sign_in(create(:user, :admin))

    get "/backoffice/jobs"

    expect(response).to have_http_status(:ok).or have_http_status(:redirect)
    follow_redirect! while response.redirect?
    expect(response).to have_http_status(:ok)
  end

  it "isn't there for anyone else" do
    get "/backoffice/jobs"
    expect(response).to have_http_status(:not_found)

    sign_in(create(:user, :editor))
    get "/backoffice/jobs"
    expect(response).to have_http_status(:not_found)
  end
end
