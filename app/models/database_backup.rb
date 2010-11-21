require 'fileutils'

class DatabaseBackup
  
  PROD_DB = "jrbh_prod"
  STAGING_DB = "worklog_staging"
  
  DAILY_BACKUP_DIR = "/home/patrik/Dropbox/backup/worklog/daily"
  MONTHLY_BACKUP_DIR = "/home/patrik/Dropbox/backup/worklog/monthly"
  
  # static methods used as runners by whenever
  
  def self.daily_backup
    backup_runner = DatabaseBackup.new(Time.now)
    backup_runner.perform_daily_backup
  end

  def self.monthly_backup
    backup_runner = DatabaseBackup.new(Time.now)
    backup_runner.perform_monthly_backup
  end

  #####################################################
  
  def initialize(now)
    @now = now
    create_directories
  end
  
  def create_directories
    FileUtils.mkdir_p(DAILY_BACKUP_DIR)
    FileUtils.mkdir_p(MONTHLY_BACKUP_DIR)
  end
  
  def perform_daily_backup
    success = dump_db(PROD_DB, generate_daily_backup_filename)
    raise "Failed to create today's DB backup!" unless success
    success = remove_daily_backups_older_than(1.week.ago(@now))
    rails "Failed to remove old daily backups!" unless success
    success = snapshot_prod_to_staging()
    rails "Failed to snapshot prod db to staging!" unless success
    success
  end
  
  def perform_monthly_backup
    success = dump_db(PROD_DB, generate_monthly_backup_filename)
    raise "Failed to create monthly DB backup!" unless success
    success
  end
  
  def generate_daily_backup_filename(time = @now)
    filename = sprintf("%s-%d-%d-%d.backup", PROD_DB, time.year, time.month, time.day)
    File.join(DAILY_BACKUP_DIR, filename)
  end

  def generate_monthly_backup_filename(time = @now)
    filename = sprintf("%s-%d-%d.backup", PROD_DB, time.year, time.month)
    File.join(MONTHLY_BACKUP_DIR, filename)
  end

  def dump_db(db_name, output_path)
    system("/usr/bin/pg_dump jrbh_prod > #{output_path}")
  end
  
  def remove_daily_backups_older_than(cutoff)
    Dir.glob(File.join(DAILY_BACKUP_DIR, "*.backup")) do |filename|
      FileUtils.rm_f filename if File.new(filename).mtime <= cutoff
    end
  end

  def snapshot_prod_to_staging(backup_name = generate_daily_backup_filename)
    success = system("/usr/bin/dropdb #{STAGING_DB} && /usr/bin/createdb #{STAGING_DB}")
    raise "Could not create a fresh staging db!" unless success
    success = system("/usr/bin/psql #{STAGING_DB} < #{backup_name}")
    railse "Failed to setup staging db from backup (#{backup_name})" unless success
    success
  end
  
end