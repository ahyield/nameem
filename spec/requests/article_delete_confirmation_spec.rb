require "rails_helper"

RSpec.describe "Deleting an article asks first" do
  let(:author) { create(:user) }

  before { sign_in(author) }

  def delete_button(article)
    action = user_destroy_article_path(slug: author, uuid: article)
    Nokogiri::HTML5.fragment(response.body).at_css("form[action='#{action}'] button")
  end

  it "asks before deleting a draft from the profile's drafts" do
    draft = create(:article, :draft, user: author)

    get user_drafts_path(slug: author), as: :turbo_stream

    button = delete_button(draft)
    expect(button["data-turbo-confirm"]).to eq("هل أنت متأكد من حذف هذه المسودة؟ لا يمكن التراجع عن ذلك.")
    expect(button["data-confirm-destructive"]).to eq("true")
    expect(button["data-turbo"]).to be_nil
  end

  it "asks before deleting from the article's own page" do
    article = create(:article, :published, user: author)

    get user_article_path(slug: author, uuid: article.permalink_param)

    expect(delete_button(article)["data-turbo-confirm"])
      .to eq("هل أنت متأكد من حذف هذا الموضوع؟ لا يمكن التراجع عن ذلك.")
  end

  it "takes a deleted draft out of the profile's list, keeping the author on the drafts tab" do
    draft = create(:article, :draft, user: author)
    other = create(:article, :draft, user: author)

    delete user_destroy_article_path(slug: author, uuid: draft), params: { from: "list" }, as: :turbo_stream

    expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    expect(response.body).to include(%(<turbo-stream action="remove" target="article_#{draft.id}">))
    expect(response.body).not_to include("article_#{other.id}")
    expect(Article.exists?(draft.id)).to be(false)
  end

  it "sends the author back to their profile with a See Other, as Turbo expects" do
    article = create(:article, :published, user: author)

    delete user_destroy_article_path(slug: author, uuid: article)

    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(user_path(author))
  end
end
