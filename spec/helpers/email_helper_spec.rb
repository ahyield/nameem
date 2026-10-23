require "rails_helper"

RSpec.describe EmailHelper do
  describe "#email_week_range" do
    it "names the month once when the week stays inside it" do
      expect(helper.email_week_range(Time.zone.local(2026, 10, 24))).to eq("17 – 24 أكتوبر")
    end

    it "names both months when the week crosses into a new one" do
      expect(helper.email_week_range(Time.zone.local(2026, 11, 3))).to eq("27 أكتوبر – 3 نوفمبر")
    end
  end

  describe "#email_cover_url" do
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(io: Rails.root.join("spec/fixtures/files/avatar-3.jpeg").open,
                                             filename: "cover.jpeg", content_type: "image/jpeg")
    end

    it "returns nothing for an article without images" do
      expect(helper.email_cover_url(build(:article), [10, 10])).to be_nil
    end

    it "crops the first image embedded in the article body" do
      html = %(<p>نص</p><img src="https://nameem.com/rails/active_storage/blobs/proxy/#{blob.signed_id}/cover.jpeg">)
      url = helper.email_cover_url(build(:article, content_html: html), [10, 10])

      expect(url).to include("/rails/active_storage/representations/")
    end

    it "ignores images hosted elsewhere and unknown blobs" do
      external = build(:article, content_html: %(<img src="https://example.com/photo.jpg">))
      forged = build(:article, content_html: %(<img src="/rails/active_storage/blobs/proxy/forged/x.jpg">))

      expect(helper.email_cover_url(external, [10, 10])).to be_nil
      expect(helper.email_cover_url(forged, [10, 10])).to be_nil
    end
  end

  describe "#email_actor_names" do
    def group_of(names, moderation: false)
      actors = names.map { |name| build(:user, first_name: name, last_name: "") }
      notifications = [instance_double(Notification, moderation?: moderation)]
      instance_double(NotificationDigest::Group, actors:, moderation?: moderation, notifications:)
    end

    it "names up to two people and counts the rest in correct Arabic" do
      expect(helper.email_actor_names(group_of(%w[أحمد]))).to eq("أحمد")
      expect(helper.email_actor_names(group_of(%w[أحمد سارة]))).to eq("أحمد وسارة")
      expect(helper.email_actor_names(group_of(%w[أحمد سارة ليلى]))).to eq("أحمد وسارة وآخر")
      expect(helper.email_actor_names(group_of(%w[أحمد سارة ليلى منى]))).to eq("أحمد وسارة وآخران")
      expect(helper.email_actor_names(group_of(%w[أ ب ج د ه و]))).to eq("أ وب و4 آخرين")
      expect(helper.email_actor_names(group_of(Array.new(14) { |i| "قارئ#{i}" }))).to eq("قارئ0 وقارئ1 و12 آخر")
    end

    it "signs moderation notices as the team" do
      expect(helper.email_actor_names(group_of(%w[مشرف], moderation: true))).to eq("فريق نميم")
    end
  end
end
