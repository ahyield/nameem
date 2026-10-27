require "rails_helper"
require "rake"

RSpec.describe "seo:backfill", type: :task do
  before { Rails.application.load_tasks unless Rake::Task.task_defined?("seo:backfill") }

  it "backfills articles and says how many changed" do
    allow(Article).to receive(:backfill_seo).and_return(3)

    Rake::Task["seo:backfill"].reenable
    expect { Rake::Task["seo:backfill"].invoke }.to output("Updated 3 articles\n").to_stdout
  end
end
