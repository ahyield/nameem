require "rails_helper"

RSpec.describe CoverImageHelper do
  let(:blob) do
    ActiveStorage::Blob.create_and_upload!(io: Rails.root.join("spec/fixtures/files/avatar-3.jpeg").open,
                                           filename: "cover.jpeg", content_type: "image/jpeg")
  end
  let(:article) do
    build(:article, content_html: %(<img src="https://nameem.com/rails/active_storage/blobs/proxy/#{blob.signed_id}/c.jpeg">))
  end

  describe "#cover_image_url" do
    it "crops around the busiest part of the image rather than its middle" do
      allow(blob).to receive(:variant).and_call_original
      allow(ActiveStorage::Blob).to receive(:find_signed).and_return(blob)

      helper.cover_image_url(article, [300, 200])

      expect(blob).to have_received(:variant).with(resize_to_fill: [300, 200, { crop: :attention }])
    end
  end

  describe "#card_cover_url" do
    it "uses the cropped cover when there is one" do
      expect(helper.card_cover_url(article, [300, 200])).to include("/rails/active_storage/representations/")
    end

    it "falls back to the original image when it can't be cropped" do
      external = build(:article, content_html: %(<img src="https://example.com/photo.jpg">))

      expect(helper.card_cover_url(external, [300, 200])).to eq("https://example.com/photo.jpg")
    end

    it "returns nothing for an article without images" do
      expect(helper.card_cover_url(build(:article), [300, 200])).to be_nil
    end
  end
end
