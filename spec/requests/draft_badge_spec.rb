require "rails_helper"

RSpec.describe "Draft badge" do
  let(:author) { create(:user) }
  let(:draft) { create(:article, :draft, user: author) }
  let(:published) { create(:article, :published, user: author) }

  before { sign_in(author) }

  it "marks a draft in the editor and on its page" do
    get user_edit_article_path(slug: author.slug, uuid: draft.uuid)
    expect(response.body).to include("لا يراه القرّاء بعد")

    get user_article_path(slug: author, uuid: draft.permalink_param)
    expect(response.body).to include("لا يراه القرّاء بعد")
  end

  it "marks a new story as a draft" do
    get new_story_path

    expect(response.body).to include("لا يراه القرّاء بعد")
  end

  it "doesn't mark a published article" do
    get user_edit_article_path(slug: author.slug, uuid: published.uuid)
    expect(response.body).not_to include("لا يراه القرّاء بعد")

    get user_article_path(slug: author, uuid: published.permalink_param)
    expect(response.body).not_to include("لا يراه القرّاء بعد")
  end
end
