require "rails_helper"

RSpec.describe NotificationDigest do
  let(:reader) { create(:user) }
  let(:article) { create(:article, :published, user: reader) }
  let(:helpers) { ApplicationController.new.view_context.extend(NotificationsHelper) }

  def like_from(name, at:)
    liker = create(:user, first_name: name)
    create(:notification, recipient: reader, actor: liker, action: :liked,
                          notifiable: create(:article_like, article:, user: liker), created_at: at)
  end

  it "groups the same action on the same article, newest activity first" do
    likes = [like_from("أحمد", at: 2.hours.ago), like_from("سارة", at: 1.hour.ago)]
    follow = create(:notification, recipient: reader, action: :followed,
                                   notifiable: create(:follow, followable: reader), created_at: 3.hours.ago)

    groups = described_class.new(likes + [follow], helpers).groups

    expect(groups.map(&:action)).to eq(%w[liked followed])
    expect(groups.first.actors.map(&:first_name)).to contain_exactly("أحمد", "سارة")
    expect(groups.first.article).to eq(article)
    expect(groups.first.label).to eq("إعجاب بموضوعك")
  end

  it "keeps the comment of a single comment notification for quoting" do
    comment = create(:comment, article:, body: "تعليق للاقتباس")
    group = described_class.new([Notification.find_by!(notifiable: comment)], helpers).groups.sole

    expect(group.comment).to eq(comment)
  end

  it "leaves out notifications whose like or comment was deleted" do
    gone = like_from("أحمد", at: 1.hour.ago)
    gone.notifiable.delete

    expect(described_class.new([gone.reload], helpers).groups).to be_empty
  end

  it "summarises activity by kind" do
    notifications = Array.new(3) { |i| like_from("قارئ #{i}", at: i.hours.ago) }
    notifications << create(:notification, recipient: reader, action: :followed,
                                           notifiable: create(:follow, followable: reader))

    expect(described_class.new(notifications, helpers).summary).to eq("3 إعجابات · متابعة")
  end

  it "uses the singular noun past ten" do
    notifications = Array.new(11) { |i| like_from("قارئ #{i}", at: i.minutes.ago) }
    expect(described_class.new(notifications, helpers).summary).to eq("11 إعجاب")
  end

  it "groups notices about content that's gone by the report itself" do
    report = create(:report, reportable: create(:comment, user: reader))
    report.reportable.destroy
    notice = create(:notification, recipient: reader, action: :content_removed, notifiable: report.reload)

    group = described_class.new([notice], helpers).groups.sole

    expect(group.article).to be_nil
    expect(group).to be_moderation
  end
end
