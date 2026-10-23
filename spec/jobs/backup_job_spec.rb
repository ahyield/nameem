require "rails_helper"

RSpec.describe BackupJob do
  it "runs a database backup" do
    backup = instance_double(Backup::CreateBackup, perform: true)
    allow(Backup::CreateBackup).to receive(:new).and_return(backup)

    described_class.perform_now

    expect(backup).to have_received(:perform)
  end
end
