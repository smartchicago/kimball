# encoding: utf-8

##
# Backup Generated: my_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t my_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#
require 'yaml'
Model.new(:my_backup, 'Description for my_backup') do
  env_file = File.dirname(__FILE__) + '/../../config/local_env.yml'
  defaults = File.dirname(__FILE__) + '/../../config/sample.local_env.yml'

  YAML.load(File.open(env_file)).each do |key, value|
    ENV[key.to_s] = value
  end if File.exist?(env_file)

  # load in defaults unless they are already set
  YAML.load(File.open(defaults)).each do |key, value|
    ENV[key.to_s] = value unless ENV[key]
  end
  ##
  # Archive [Archive]
  #
  # Adding a file or directory (including sub-directories):
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/directory/"
  #
  # Excluding a file or directory (including sub-directories):
  #   archive.exclude "/path/to/an/excluded_file.rb"
  #   archive.exclude "/path/to/an/excluded_directory
  #
  # By default, relative paths will be relative to the directory
  # where `backup perform` is executed, and they will be expanded
  # to the root of the filesystem when added to the archive.
  #
  # If a `root` path is set, relative paths will be relative to the
  # given `root` path and will not be expanded when added to the archive.
  #
  #   archive.root '/path/to/archive/root'
  #
  # archive :my_archive do |archive|
  #   # Run the `tar` command using `sudo`
  #   # archive.use_sudo
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/folder/"
  #   archive.exclude "/path/to/a/excluded_file.rb"
  #   archive.exclude "/path/to/a/excluded_folder"
  # end

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = ENV['RAILS_ENV']
    db.username           = 'root'
    db.password           = 'password'
    db.host               = 'localhost'
    db.port               = 3306
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    db.additional_options = ['--quick', '--single-transaction']
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  store_with S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = ENV['AWS_API_TOKEN']
    s3.secret_access_key = ENV['AWS_API_SECRET']
    # Or, to use a IAM Profile:
    # s3.use_iam_profile = true

    s3.region            = 'us-east-1'
    s3.bucket            = ENV['AWS_S3_BUCKET']
    s3.path              = "/patterns_backups_#{ENV['RAILS_ENV']}"
    s3.keep              = 50
    # s3.keep              = Time.now - 2592000 # Remove all backups older than 1 month.
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = '~/backups/'
    local.keep       = 5
    # local.keep       = Time.now - 2592000 # Remove all backups older than 1 month.
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  notify_by Mail do |mail|
    mail.on_success           = false
    mail.on_warning           = true
    mail.on_failure           = true

    mail.from                 = ENV['MAILER_SENDER']
    mail.to                   = ENV['MAIL_ADMIN']
    mail.address              = ENV['SMTP_HOST']
    mail.port                 = ENV['SMTP_PORT']
    mail.domain               = ENV["#{ENV['RAILS_ENV'].upcase}_SERVER"]
    mail.user_name            = ENV['SMTP_USERNAME']
    mail.password             = ENV['SMTP_PASSWORD']
    mail.authentication       = 'plain'
    mail.encryption           = :starttls
  end
end
