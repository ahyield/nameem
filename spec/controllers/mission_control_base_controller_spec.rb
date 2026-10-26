require "rails_helper"

RSpec.describe MissionControlBaseController do
  def require_admin_as(user)
    controller = described_class.new
    allow(controller).to receive_messages(current_user: user, render_not_found: nil)
    controller.send(:require_admin)
    controller
  end

  it "turns away anyone who isn't an admin, even past the route" do
    expect(require_admin_as(build(:user))).to have_received(:render_not_found)
    expect(require_admin_as(nil)).to have_received(:render_not_found)
  end

  it "lets an admin through" do
    expect(require_admin_as(build(:user, :admin))).not_to have_received(:render_not_found)
  end
end
