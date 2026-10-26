require "rails_helper"

RSpec.describe ArticleBodyHelper do
  let(:blob) do
    ActiveStorage::Blob.create_and_upload!(io: Rails.root.join("spec/fixtures/files/avatar-3.jpeg").open,
                                           filename: "photo.jpeg", content_type: "image/jpeg",
                                           metadata: { "width" => 3200, "height" => 2400, "analyzed" => true })
  end
  let(:original) { "https://nameem.com/rails/active_storage/blobs/proxy/#{blob.signed_id}/photo.jpeg" }

  def body(html)
    Nokogiri::HTML5.fragment(helper.article_body(build(:article, content_html: html, updated_at: Time.current)))
  end

  it "serves uploaded images at reading size, keeps the original for the viewer and sizes them up front" do
    img = body(%(<figure><img class="py-4" src="#{original}"><figcaption>غروب</figcaption></figure>)).at_css("img")

    expect(img["src"]).to include("/rails/active_storage/representations/")
    expect(img["data-full-src"]).to eq(original)
    expect([img["width"], img["height"]]).to eq(%w[1600 1200])
    expect(img["class"]).to be_nil
    expect(img["loading"]).to be_nil
  end

  it "lazy-loads every image after the first and keeps captions" do
    html = %(<figure><img src="#{original}"></figure><figure><img src="https://example.com/a.jpg"><figcaption>غروب</figcaption></figure>)
    fragment = body(html)
    external = fragment.css("img").last

    expect(external["src"]).to eq("https://example.com/a.jpg")
    expect(external["data-full-src"]).to be_nil
    expect([external["loading"], external["decoding"]]).to eq(%w[lazy async])
    expect(fragment.at_css("figcaption").text).to eq("غروب")
  end

  it "still strips anything unsafe" do
    fragment = body(%(<p onclick="x()">نص</p><script>alert(1)</script><img src="x.jpg" onerror="alert(1)">))

    expect(fragment.to_html).not_to include("script", "onclick", "onerror")
  end
end
