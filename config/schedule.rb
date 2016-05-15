# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
path = File.expand_path(File.dirname(File.dirname(__FILE__)))
set :output, "#{path}/log/cron_log.log"
#
every 30.minutes do
  command "backup perform --trigger my_backup -r #{path}/Backup/"
end

# this queues up all the email/sms for the day!
every :weekday, at: "8:00am" do
  runner "User.send_all_reminders"
  runner "Person.send_all_reminders"
end
#
# every 4.days do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
