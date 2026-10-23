require "rails_helper"

RSpec.describe "Feed suggestions" do
  let(:reader) { create(:user) }
  let(:followed_author) { create(:user, :picked, first_name: "متابَع") }
  let!(:new_author) { create(:user, :picked, first_name: "جديد") }

  it "suggests picked authors the reader doesn't follow yet" do
    create(:follow, follower: reader, followable: followed_author)
    authenticate_user(reader)

    get feed_index_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(new_author.name)
    expect(response.body).not_to include(followed_author.name)
  end

  it "suggests popular topics the reader doesn't follow yet" do
    followed_topic = create(:tag, name: "شعر")
    new_topic = create(:tag, name: "قصة")
    create(:article, :published).tags << [followed_topic, new_topic]
    create(:follow, :tag_follow, follower: reader, followable: followed_topic)
    authenticate_user(reader)

    get feed_index_path

    expect(response.body).to include(new_topic.name)
    expect(response.body).not_to include(">#{followed_topic.name}<")
  end
end
