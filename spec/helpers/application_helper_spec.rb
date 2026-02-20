require "rails_helper"

RSpec.describe ApplicationHelper do
  context "when #active? nav bar selected" do
    it "returns active class" do
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: "/"))
      expect(helper.active_nav_class("/")).to eq("border-blue-500 text-gray-900")
    end
  end

  context "when non #active? nav bar not selected" do
    it "returns inactive class" do
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: "/"))
      expect(helper.active_nav_class("/test"))
        .to eq("border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700")
    end
  end

  context "when #active_settings_sidebar selected" do
    it "returns active class" do
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: "/"))
      expect(helper.active_settings_sidebar("/")).to eq("bg-gray-50 text-blue-600")
    end
  end

  context "when non #active_settings_sidebar not selected" do
    it "returns inactive class" do
      allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: "/"))
      expect(helper.active_settings_sidebar("/test"))
        .to eq("text-gray-700 hover:text-blue-600 hover:bg-gray-50")
    end
  end

  context "when #first_paragraph is called" do
    it "returns the first paragraph" do
      article = Article.create!(
        content:      { ops: [{ insert: "New Article" }] },
        content_html: "<p>New Article</p>",
        user:         User.create(email: "test@test.com", slug: "test")
      )

      expect(helper.first_paragraph(article)).to eq("New Article")
    end
  end

  context "when #article_cover is called" do
    it "returns the first image" do
      article = Article.create!(
        title:        "New Article",
        content:      { ops: [{ insert: { customImage: { url: "https://test.com/image.jpeg" } } }] },
        content_html: '<p>text</p><figure><img src="https://test.com/image.jpeg"></figure>',
        user:         User.create(email: "test@test.com", slug: "test")
      )

      expect(helper.article_cover(article)).to eq("https://test.com/image.jpeg")
    end
  end

  context "when #short_date is called" do
    it "returns the short date" do
      date = Time.zone.today
      expect(helper.short_date(date)).to eq(I18n.l(date, format: :short, locale: :ar))
    end
  end
end
