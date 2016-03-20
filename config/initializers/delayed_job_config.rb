# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term

delayed_job_logfile = File.join(Rails.root, 'log', 'delayed_job.log')
FileUtils.touch(delayed_job_logfile) unless File.exist?(delayed_job_logfile)

Delayed::Worker.logger = Logger.new(delayed_job_logfile)
