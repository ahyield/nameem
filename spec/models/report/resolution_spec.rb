require "rails_helper"

RSpec.describe Report::Resolution do
  let!(:site) { User.find_by(id: 1) || create(:user, id: 1) }
  let(:reviewer) { create(:editor) }
  let(:author) { create(:user) }
  let(:comment) { create(:comment, user: author) }
  let!(:first) { create(:report, reportable: comment) }
  let!(:second) { create(:report, reportable: comment, reason: :harassment) }

  def resolve(report = first, **)
    described_class.new(report, reviewer:, **).call
  end

  it "dismisses every pending report about the item" do
    resolved = resolve(decision: "dismiss", note: "لا مخالفة")

    expect(resolved).to contain_exactly(first, second)
    expect([first.reload, second.reload]).to all(be_dismissed)
    expect(first.reviewer).to eq(reviewer)
    expect(first.resolution_note).to eq("لا مخالفة")
    expect(Comment.exists?(comment.id)).to be(true)
  end

  it "removes the comment, warns the author and notifies each reporter" do
    expect { resolve(decision: "action", remove_content: true, warn_author: true, notify_reporters: true) }
      .to change { Notification.where(action: Notification::MODERATION_ACTIONS).count }.by(3)

    expect(Comment.exists?(comment.id)).to be(false)
    expect([first.reload, second.reload]).to all(be_actioned)
    expect(Notification.content_removed.sole.recipient).to eq(author)
    expect(Notification.report_actioned.map(&:recipient)).to contain_exactly(first.reporter, second.reporter)
    expect(Notification.last.actor).to eq(site)
  end

  it "unpublishes a reported article" do
    article = create(:article, :published, user: author)
    report = create(:report, reportable: article)

    resolve(report, decision: "action", remove_content: true)
    expect(article.reload).not_to be_published
  end

  it "acts on content that is already gone" do
    comment.destroy

    expect(resolve(decision: "action", remove_content: true, warn_author: true)).to contain_exactly(first, second)
    expect(first.reload).to be_actioned
  end

  it "suspends the author when an admin asks" do
    admin = create(:admin)
    described_class.new(first, reviewer: admin, decision: "action", note: "إساءة متكررة", suspend_author: true).call

    expect(author.reload).to be_suspended
    expect(author.suspension_reason).to eq("إساءة متكررة")
  end

  it "skips the author when their account is gone" do
    first.update_column(:reported_user_id, nil)

    expect { resolve(decision: "action", warn_author: true) }.not_to change(Notification.content_removed, :count)
    expect(first.reload).to be_actioned
  end

  it "ignores suspension from an editor" do
    resolve(decision: "action", suspend_author: true)
    expect(author.reload).not_to be_suspended
  end

  it "can act without removing or notifying" do
    expect { resolve(decision: "action") }.not_to change(Notification, :count)
    expect(Comment.exists?(comment.id)).to be(true)
    expect(first.reload).to be_actioned
  end

  it "does nothing for reports that were already resolved" do
    resolve(decision: "dismiss")
    expect(resolve(decision: "action", remove_content: true)).to be_empty
    expect(Comment.exists?(comment.id)).to be(true)
  end

  it "rejects an unknown decision" do
    resolution = described_class.new(first, reviewer:, decision: "delete everything")

    expect(resolution).not_to be_valid
    expect(resolution.call).to be_empty
    expect(first.reload).to be_pending
  end

  it "signs notices as the reviewer when there is no site account" do
    site.destroy
    resolve(decision: "action", warn_author: true)

    expect(Notification.content_removed.sole.actor).to eq(reviewer)
  end
end
