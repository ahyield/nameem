require "rails_helper"
require "rake"

RSpec.describe "announcements:dark_mode", type: :task do
  before { Rails.application.load_tasks unless Rake::Task.task_defined?("announcements:dark_mode") }

  it "passes TO, SEND and FORCE through to the announcement" do
    announcement = instance_double(Announcements::DarkMode, run: nil)
    allow(Announcements::DarkMode).to receive(:new).and_return(announcement)
    stub_const("ENV", ENV.to_h.merge("TO" => "me@example.com", "SEND" => "1"))

    Rake::Task["announcements:dark_mode"].reenable
    Rake::Task["announcements:dark_mode"].invoke

    expect(announcement).to have_received(:run).with(to: "me@example.com", deliver: true, force: false)
  end
end
