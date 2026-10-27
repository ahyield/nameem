require "rails_helper"

RSpec.describe "Images in articles" do
  it "shows uploaded images at reading size with their caption, ready for the viewer" do
    blob = ActiveStorage::Blob.create_and_upload!(io: Rails.root.join("spec/fixtures/files/avatar-3.jpeg").open,
                                                  filename: "photo.jpeg", content_type: "image/jpeg")
    original = "/rails/active_storage/blobs/proxy/#{blob.signed_id}/photo.jpeg"
    article = create(:article, :published,
                     content_html: %(<figure><img src="#{original}" alt="غروب"><figcaption>غروب على النيل</figcaption></figure>))

    get user_article_path(slug: article.user, uuid: article.permalink_param)

    expect(response.body).to include(%(data-full-src="#{original}"), "/rails/active_storage/representations/")
    expect(response.body).to include("<figcaption>غروب على النيل</figcaption>", "image-viewer")
  end
end
