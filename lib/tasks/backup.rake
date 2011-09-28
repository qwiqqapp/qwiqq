require "aws/s3"

class DatabaseDumper
  attr_reader :config

  def initialize
    @config = Rails.configuration.database_configuration[Rails.env].symbolize_keys
  end

  def dump compress=true
    file = Tempfile.new("dump")
    cmd = "mysqldump --quick --single-transaction --create-options #{mysql_options}"
    cmd += " | gzip -9" if compress
    cmd += " > #{file.path}"
    run(cmd)
    file.path
  end

  def restore path
    run "gunzip -c #{path} | mysql #{mysql_options}"
  end

  private
    def run command
      result = system(command)
      raise "Error, process exited with status #{$?.exitstatus}" unless result
    end

    def mysql_options
      cmd = ""
      cmd += " -u #{@config[:username]}" unless @config[:username].nil?
      cmd += " -p#{@config[:password]}" unless @config[:password].nil?
      cmd += " -h #{@config[:host]}" unless @config[:host].nil?
      cmd += " #{@config[:database]}"
    end
end

class BackupStore
  BUCKET = "qwiqq.backups"
  CURRENT = "qwiqq-current.txt"

  def initialize
    AWS::S3::Base.establish_connection!(
      :access_key_id => ENV["S3_KEY"], 
      :secret_access_key => ENV["S3_SECRET"])
  end

  def save dump_path, name
    AWS::S3::S3Object.store name, open(dump_path), BUCKET
    AWS::S3::S3Object.store CURRENT, name, BUCKET
  end

  def current
    AWS::S3::S3Object.value CURRENT, BUCKET
  end

  def fetch name
    file = Tempfile.new("dump")
    open(file.path, "wb") do |f|
      AWS::S3::S3Object.stream(name, BUCKET) do |chunk|
        f.write chunk
      end
    end
    file
  end
end

namespace :db do
  desc "Creates a dump of the current environment's database and pushes it to S3"
  task :backup do
    name = "qwiqq-#{Time.now.utc.strftime("%Y%m%d%H%M")}.sql.gz"
    dumper = DatabaseDumper.new
    store = BackupStore.new
    store.save dumper.dump, name
  end

  desc "Restores the current environment's database from the most recent dump found in S3"
  task :restore do
    raise "Not in production!" if Rails.env.production?
    dumper = DatabaseDumper.new
    store = BackupStore.new
    current = store.current
    print "Are you sure you want to restore the database dump '#{current}' to local database '#{dumper.config[:database]}'? YES/[NO]: "
    return unless STDIN.gets.chomp == "YES"
    dumper.restore store.fetch(current).path 
  end
end

