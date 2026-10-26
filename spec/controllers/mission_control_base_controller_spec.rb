require "rails_helper"

RSpec.describe MissionControlBaseController do
  it "turns away anyone who isn't an admin, even past the route" do
    controller = described_class.new
    allow(controller).to receive(:current_user).and_return(build(:user))
    allow(controller).to receive(:render_not_found)

    controller.send(:require_admin)

    expect(controller).to have_received(:render_not_found)
  end
end
