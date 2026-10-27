require "rails_helper"

RSpec.describe NotificationsHelper do
  let(:article) { create(:article, :published) }
  let(:report) { create(:report, reportable: create(:comment, article:)) }
  let(:notification) { create(:notification, notifiable: report, action: :report_actioned) }

  it "signs moderation notices as the team" do
    expect(helper.notification_actor_name(notification)).to eq("فريق نميم")
    expect(helper.notification_message(notification)).to eq("راجع بلاغك واتخذ إجراءً بشأنه")
    expect(helper.notification_action_icon(notification)).to include("svg")
  end

  it "uses the actor's name for everything else" do
    liked = create(:notification, action: :liked)
    expect(helper.notification_actor_name(liked)).to eq(liked.actor.name)
  end

  it "links a report notice to the article" do
    expect(helper.notification_article(notification)).to eq(article)
    expect(helper.notification_path_for(notification)).to eq(user_article_path(slug: article.user, uuid: article.permalink_param))
  end

  describe "#notification_path_for and #notification_article" do
    let(:reader) { create(:user) }
    let(:comment) { create(:comment, article:) }
    let(:article_path) { user_article_path(slug: article.user, uuid: article.permalink_param) }

    def notice(notifiable, action = :liked)
      build(:notification, notifiable:, action:)
    end

    it "points likes, comments and comment likes to the article" do
      [create(:article_like, article:), comment, create(:comment_like, comment:)].each do |notifiable|
        expect(helper.notification_path_for(notice(notifiable))).to eq(article_path)
        expect(helper.notification_article(notice(notifiable))).to eq(article)
      end
    end

    it "points article notices to the article" do
      expect(helper.notification_path_for(notice(article, :featured))).to eq(article_path)
    end

    it "points follows to the follower" do
      follow = notice(create(:follow, follower: reader, followable: create(:user)), :followed)
      follow.actor = reader

      expect(helper.notification_path_for(follow)).to eq(user_path(slug: reader))
      expect(helper.notification_article(follow)).to be_nil
    end

    it "has no link once the content is gone" do
      orphan = notice(report, :content_removed)
      report.reportable.destroy
      orphan.notifiable = report.reload

      expect(helper.notification_path_for(orphan)).to be_nil
      expect(helper.notification_article(orphan)).to be_nil
    end
  end
end
