desc 'back up the db to S3'
task :backup do
  sh "backup perform --trigger my_backup -r /var/www/logan-production/current/"
end