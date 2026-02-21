require "fileutils"
require "open3"
require "aws-sdk-s3"

module Backup
  class CreateBackup
    def initialize
      @db_config       = ActiveRecord::Base.connection_db_config.configuration_hash
      @backup_dir      = Rails.root.join("db/backups").to_s
      @timestamp       = Time.zone.now.strftime("%Y%m%d%H%M%S")
      @backup_file     = File.join(backup_dir, "#{db_config[:database]}_backup_#{timestamp}.sql")
      @bucket_name     = "nameem-production-db-backups"
      @compressed_file = "#{backup_file}.gz"
    end

    def perform
      create_backup
      compress_backup
      upload_to_s3
      delete_local_backup
    end

    private

    attr_reader :db_config, :backup_dir, :backup_file, :compressed_file, :timestamp, :bucket_name

    def mysqldump_args
      [
        "mysqldump", "--protocol=TCP",
        "-u", db_config[:username].to_s,
        "-h", db_config[:host].to_s,
        "-p#{db_config[:password]}",
        "-c", "-q",
        db_config[:database].to_s
      ]
    end

    def create_backup
      FileUtils.mkdir_p(backup_dir)

      Rails.logger.debug { "Running mysqldump for #{db_config[:database]}" }

      stderr_output = nil
      status = Open3.popen3(*mysqldump_args) do |_stdin, stdout, stderr, wait_thr|
        IO.copy_stream(stdout, backup_file)
        stderr_output = stderr.read
        wait_thr.value
      end

      unless status.success?
        FileUtils.rm_f(backup_file)
        Rails.logger.error "Backup failed: #{stderr_output}"
        raise "Backup failed: #{stderr_output}"
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
      s3_client = Aws::S3::Client.new(region:            "eu-central-1",
                                      access_key_id:     Rails.application.credentials.dig(:aws, :access_key_id),
                                      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key))
      object_key = File.basename(compressed_file)

      begin
        s3_client.put_object(
          bucket: bucket_name,
          key:    object_key,
          body:   File.open(compressed_file, "rb")
        )
        Rails.logger.debug { "Backup uploaded to S3 successfully: s3://#{bucket_name}/#{object_key}" }
      rescue Aws::S3::Errors::ServiceError => e
        Rails.logger.fatal "An error occurred while uploading the backup to S3: #{e.message}"
      end
    end

    def delete_local_backup
      FileUtils.rm_f(compressed_file)
      FileUtils.rm_f(backup_file)

      Rails.logger.info "Local backup file deleted: #{compressed_file}, #{backup_file}"
    rescue StandardError => e
      Rails.logger.error "An error occurred while deleting the local backup: #{e.message}"
    end
  end
end
