require "rails_helper"

RSpec.describe UpdateArticleViewsJob, type: :job do
  let(:article) { create(:article, :published, plausible_last_synced_at: nil, views_count: 0, visitors_count: 0) }
  let(:plausible_client) { instance_double(PlausibleClient::Plausible) }

  before do
    allow(PlausibleClient::Plausible).to receive(:new).and_return(plausible_client)
  end

  describe "#perform" do
    context "when article has not been synced recently" do
      it "updates article stats" do
        allow(plausible_client).to receive(:aggregate).and_return({ pageviews: 100, visitors: 50 })

        expect do
          described_class.perform_now
        end.to change { article.reload.views_count }.from(0).to(100)
                                                    .and change { article.reload.visitors_count }.from(0).to(50)

        expect(article.plausible_last_synced_at).to be_within(1.second).of(Time.current)
      end
    end

    context "when article has been synced recently" do
      before do
        article.update(plausible_last_synced_at: 2.hours.ago)
      end

      it "skips updating" do
        expect(PlausibleClient::Plausible).not_to receive(:new)

        described_class.perform_now
      end
    end

    context "when an error occurs during update" do
      it "logs error and captures in Sentry" do
        allow(plausible_client).to receive(:aggregate).and_raise(StandardError.new("Boom"))

        expect(Rails.logger).to receive(:error).with(/Error updating article #{article.id}: Boom/)
        expect(Sentry).to receive(:capture_exception).with(instance_of(StandardError), extra: { article_id: article.id })

        described_class.perform_now
      end
    end
  end
end
