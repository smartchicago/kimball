# https://gist.github.com/defunkt/206253/raw/7c5895310a5e932e001381d0b47c7746e1e18d09/gistfile1.rb
# unicorn_rails -c config/unicorn.rb -E production -D

rails_env = ENV['RAILS_ENV'] || 'production'

# 16 workers and 1 master
# worker_processes (rails_env == 'production' ? 16 : 4)
#worker_processes 4
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 4)

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
listen "/tmp/logan-#{rails_env}.sock", backlog: 2048

before_exec do |_server|
  ENV['BUNDLE_GEMFILE'] = "/var/www/logan-#{rails_env}/current/Gemfile"
end

before_fork do |server, _worker|
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = Dir.pwd + '/tmp/pids/unicorn.pid.oldbin'
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |_server, _worker|
  ##
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  ActiveRecord::Base.establish_connection

  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to git:git

  # begin
  #   uid, gid = Process.euid, Process.egid
  #   user, group = 'logan', 'logan'
  #   target_uid = Etc.getpwnam(user).uid
  #   target_gid = Etc.getgrnam(group).gid
  #   worker.tmp.chown(target_uid, target_gid)
  #   if uid != target_uid || gid != target_gid
  #     Process.initgroups(user, target_gid)
  #     Process::GID.change_privilege(target_gid)
  #     Process::UID.change_privilege(target_uid)
  #   end
  # rescue => e
  #   if rails_env == 'development'
  #     STDERR.puts "couldn't change user, oh well"
  #   else
  #     raise e
  #   end
  # end
end
