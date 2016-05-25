# app/jobs/twilio/send_messages.rb
#
# module TwilioSender
# Send twilio messages to a list of phone numbers
#
# FIXME: Refactor and re-enable cop
# rubocop:disable Style/StructInheritance
#
class SendEventInvitationsSmsJob < Struct.new(:to, :event)

  def enqueue(job)
    # job.delayed_reference_id   =
    # job.delayed_reference_type = ''
    Rails.logger.info '[SendEventInvitationsSms] job enqueued'
    job.save!
  end

  def max_attempts
    1
  end

  def perform
    # step 1: check to see if we already have a context for the person
    #   yes: get ttl and re-enque for after ttl
    #   no: go to step 2
    # step 2: check if we are after hours
    #   yes: requeue for 8:30am
    #   no: set context with expire and send!


    # context = Redis.current.get("wit_context:#{to.id}")
    # if context.nil?  && !time_requeue? # no context, free to send
    # context is symbols here, but will be string keys after json.
    context = { person_id: to.id,
                event_id: event.id,
                'reference_time' => event.start_datetime,
                'reference_time_slot' =>  event.bot_duration }.to_json
    Redis.current.set("wit_context:#{to.id}", context)
    Redis.current.expire("wit_context:#{to.id}", 7200) # two hours
    EventInvitationSms.new(to: to, event: event).send
    # elsif time_requeue?
    #   Delayed::Job.enqueue(SendEventInvitationsSmsJob.new(to, event), run_at: run_in_business_hours)
    # else # we have a context, wait till we time out.
    #   ttl = Redis.current.ttl("wit_context:#{to.id}") # ttl is in seconds
    #   requeue_at = Time.current + ttl.seconds
    #   Delayed::Job.enqueue(SendEventInvitationsSmsJob.new(to, event), run_at: requeue_at)
    # end
    sleep(1) # twilio rate limiting.
  end

  def before(job)
  end

  def after(job)
  end

  def success(job)
  end

  private

    def time_requeue?
      # yes if before 8:30am and yes if after 8pm
      return true if Time.current < DateTime.current.change({ hour: 8, minute: 30 })
      return true if Time.current > DateTime.current.change({ hour: 20, minute: 0 })

      false
    end

    def run_in_business_hours   # different run_at times
      if Time.current > Time.zone.parse('20:00')
        DateTime.tomorrow.change({ hour: 8, minute: 30 })
      elsif Time.current < Time.zone.parse('8:00')
        DateTime.current.change({ hour: 8, minute: 30 })
      end
    end
end
# rubocop:enable Style/StructInheritance
