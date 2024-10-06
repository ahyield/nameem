class BackupJob < ApplicationJob
  def perform
    Backup::CreateBackup.new.perform
  end
end
