require "rails_helper"
require "backup/create_backup"

RSpec.describe Backup::CreateBackup do
  subject(:backup) { described_class.new }

  describe "compressing the dump" do
    let(:dump_path) { backup.send(:backup_file) }
    let(:gzip_path) { backup.send(:compressed_file) }

    before do
      FileUtils.mkdir_p(File.dirname(dump_path))
      File.write(dump_path, "-- SQL dump\nCREATE TABLE things (id int);\n")
    end

    after { FileUtils.rm_f([dump_path, gzip_path]) }

    it "gzips the dump in place without going through a shell" do
      backup.send(:compress_backup)

      expect(File).to exist(gzip_path)
      expect(File).not_to exist(dump_path)
      expect(Zlib::GzipReader.open(gzip_path, &:read)).to include("CREATE TABLE things")
    end
  end
end
