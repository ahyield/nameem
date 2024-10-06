require "English"
require "fileutils"

module Backup
  class CreateBackup
    def initialize
      @db_config       = ActiveRecord::Base.connection_db_config.configuration_hash
      @backup_dir      = Rails.root.join("db/backups").to_s
      @timestamp       = Time.zone.now.strftime("%Y%m%d%H%M%S")
      @backup_file     = File.join(backup_dir, "#{db_config[:database]}_backup_#{timestamp}.sql")
      @bucket_name     = "nameem-production-db-backups"
      @compressed_file = "#{backup_file}.gz"
      @db_url          = "mysql2://#{db_config[:username]}:#{db_config[:password]}@#{db_config[:host]}/#{db_config[:database]}"
    end

    def perform
      create_backup
      compress_backup
      upload_to_s3
    end

    private

    attr_reader :db_config, :backup_dir, :backup_file, :compressed_file, :timestamp, :bucket_name, :db_url

    def create_backup
      command = "mysqldump --protocol=TCP #{db_url}" \
                "-c -q #{db_config[:database]} > #{backup_file}"
      Rails.logger.debug { "Running: #{command}" }
      system(command)

      unless $CHILD_STATUS.success?
        Rails.logger.debug "Backup failed. Please check the command and credentials."
        raise "Backup failed. Please check the command and credentials."
      end

      Rails.logger.debug { "Backup completed successfully: #{backup_file}" }
    end

    def compress_backup
      compress_command = "gzip #{backup_file}"
      Rails.logger.debug { "Compressing backup file: #{compress_command}" }
      system(compress_command)

      unless $CHILD_STATUS.success?
        Rails.logger.debug "Compression failed. Please check the command and file."
        raise "Compression failed. Please check the command and file."
      end

      Rails.logger.debug { "Backup compressed successfully: #{compressed_file}" }
    end

    def upload_to_s3
      compressed_backup = File.open(compressed_file)

      blob = ActiveStorage::Blob.create_and_upload!(
        io:           compressed_backup,
        filename:     File.basename(compressed_file),
        content_type: "application/gzip",
        service_name: :amazon
      )

      # Attach to the different bucket
      ActiveStorage::Blob.service.bucket(bucket_name).object(blob.key).upload_file(compressed_file)
      url = Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true)
      Rails.logger.debug { "Backup uploaded to S3 successfully: #{url}" }
    rescue StandardError => e
      Rails.logger.debug { "An error occurred while uploading the backup to S3: #{e.message}" }
    end
  end
end
