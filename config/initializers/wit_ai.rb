require 'wit'

# note, context: it's a hash with string keys. allways string keys
# that's because we save it in json in redis for reuse
actions = {
  say: lambda do |_session_id, context, msg|
    # this is where we text.
    puts "in say"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    person = Person.find_by(id: context['person_id'])
    ::WitSms.new(to: person, msg: msg).send
    context
  end,
  merge: lambda do |_session_id, context, entities, _msg|
    # this is where all the work happens. I get it now.
    # wit relies on us to know what contexts and entites result in
    # entirely new contexts and entities.

    # this whole thing is such a hack
    # needs to be a state machine. for sure.

    context.merge!(entities) # how we know what happened
    puts "after entities merge"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    # handle initial yes or no

    # # when the person sends an unintelligible date
    if context['want_interview'] && context['datetime'].nil?
      puts "want an interview, but no date"
      # they may have previously sent a good date.
      context.delete('date_is_valid')
      context['date_is_invalid'] = true
    end

    if context['want_interview'].nil? && context['yes_no'] && context['reference_time_slot']
      puts "first 'yes or no' for whatever it's worth"
      case context['yes_no'][0]['value']
      when 'yes'
        puts "we have a yes! in first yes_no"
        context.delete('refuse_interview')
        context['want_interview'] = true
      when 'no'
        puts "we have a no.... in first yes_no"
        context['refuse_interview'] = true
      end
      # context.delete('yes_no')
    end

    # handle confirming date
    if context['date_is_valid'] && context['yes_no']
      puts "confirming date yes_no"

      # context.delete('reference_time_slot')
      # context.delete('want_interview')
      # context.delete('human_date')
      # context.delete('date_is_valid')
      case context['yes_no'][0]['value']
      when 'yes'
        context.delete('date_not_confirmed') # might be second attempt
        context['date_confirmed'] = true
      when 'no'
        context.delete('datetime')
        context.delete('date_is_valid')
        context.delete('date_confirmed') # not possible, I think.
        context['date_not_confirmed'] = true
      end
      # context.delete('yes_no') # start afresh, maybe?
    end

    # case when we have a valid date
    if context['datetime'] # should we check it's an interval?
      puts "we have a datetime!"
      # context.delete('reference_time_slot')
      # context.delete('want_interview')
      context.delete('date_is_invalid')
      context.delete('date_not_confirmed')
      context['date_is_valid'] = true
      # we add human date in a function below
    end



    # when the person sends a command of any sort
    if context['command']
      case context['command'][0]['value']
      when 'decline'
        context.delete('event_id')
        context.delete('want_interview') # can decline at any time
        context['decline'] = true
        context['refuse_interview'] = true
      end
      context.delete('command') # start afresh
    end


    # might not need this.
    if context['date_not_confirmed']

      # must remove this context if we get a new datetime
      # currently, if a person doesn't confirm the date, we enter into a loop.
      # how do I know that this is a persons second attempt to add a datetime?
    end


    # handling locking for event. extend lock!
    if context['event_id'] && Redis.current.get("event_lock:#{context['person_id']}") == context['event_id']
      Redis.current.setex("event_lock:#{context['person_id']}",3600,context['event_id'])
    end

    # context gets set in merge
    Redis.current.set("wit_context:#{context['person_id']}", context.to_json)
    puts "after merge"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    return context
  end,
  error: lambda do |_session_id, _context, error|
    p error.message
  end,
  get_event: lambda do |_session_id, context|
    # session ID and context will have event id in it.
    puts "in get_event"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    ei = V2::EventInvitation.find_by(id: context['event_id'])

    context.merge!({ 'reference_time' => ei.start_datetime,
                    'reference_time_slot' =>  ei.bot_duration})
  end,
  reserve_slot: lambda do |_session_id, context|
    # datetime is the time the person chose.
    puts "in reserve slot"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    ei = V2::EventInvitation.find_by(id: context['event_id'])
    person = Person.find_by(id: context['person_id'])

    times = get_times(context, ei.end_datetime)
    if times
      slots = ei.event.available_time_slots(person)
      slot = find_slot_given_times(slots,times)
      r = nil
      unless slot.blank?
        r = V2::Reservation.new(person: person,
                                  time_slot: slot,
                                  user: ei.user,
                                  event: ei.event,
                                  event_invitation: ei)
      end

      if r && r.save
        duration = r.duration / 60
        selected_time = r.start_datetime_human
        msg = "A #{duration} minute conversation has been booked for:\n#{selected_time}\nWith: #{r.user.name}, \nTel: #{r.user.phone_number}\n.You'll get a reminder that morning."
      else
        pp r.errors if r
        msg = 'It appears there are no more times available. There will be more opportunities soon!'
      end


      # cleanup context
      %w(want_interview yes_no reference_time_slot event_id reference_time datetime date_confirmed date_is_valid).each  do |i|
        context.delete(i)
      end

      Redis.current.set("wit_context:#{person.id}",context.to_json)

      # remove our lock
      Redis.current.del("event_lock:#{person.id}")
      context['reservation_msg'] = msg
    else
      # lets ask for the date again
      context['date_is_invalid'] = true
    end
    return context
  end,
  confirm_reservation: lambda do |_session_id, context|
    # person confirms reservation
    context
  end,
  cancel_reservation: lambda do |_session_id, context|
    # person cancels reservation
    context
  end,
  change_reservation: lambda do |_session_id, context|
    # person changes reservation
    context
  end,
  calendar: lambda do |_session_id, context|
    # a person's calendar for the next few days
    context
  end,
  decline_invitation: lambda do |_session_id, context|
    puts "in decline"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    # cleanup our context

    context.delete('want_interview')
    context.delete('refuse_interview')
    context.delete('reference_time_slot')
    context.delete('reference_time')
    context.delete('event_id')
    context.delete('yes_no')
    context.delete('datetime')
    context.delete('command') # possible that the decline came from a command

    # destroy the lock, should notify alexis too
    Redis.current.del("event_lock:#{context['person_id']}")
    Redis.current.set("wit_context:#{context['person_id']}",context.to_json)
    return context
  end,
  date_to_human: lambda do |_session_id, context|

    puts "in date_to_human"
    pp context
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    ei = V2::EventInvitation.find_by(id: context['event_id'])
    times = get_times(context,ei.end_datetime)
    if times
      puts 'we have times!'
      human_arr = []
      # handling multiple times
      times.each do |time|
        human_arr << "#{time[:from].strftime('%A').lstrip} from #{time[:from].strftime('%l:%M%p').lstrip} to #{time[:untill].strftime('%l:%M%p').lstrip}"
      end
      human_date = human_arr.join(' and ')
      context.delete('date_is_invalid')
      context.merge!({ 'human_date' => human_date, 'date_is_valid'=> true })
    else
      puts "why didn't we get times here?"
      context.delete('human_date')
      context.delete('date_is_valid')
      context['date_is_invalid'] = true
    end
    Redis.current.set("wit_context:#{context['person_id']}",context.to_json)
    return context
  end,
}

def find_slot_given_times(slots,times)
  slots.find do |s|
    times.find do |t| # iterating through all the times given
      next unless t[:confidence] > 0.7
      s.start_datetime > t[:from] && s.end_datetime < t[:untill]
    end
  end
end

def get_times(context, default_end)
  return nil if context['datetime'].blank?
  res = []

  context['datetime'].each do | datetime|
    if datetime['type'] == 'value'
      from = Time.zone.parse(datetime['value'])
      untill = default_end
    else # we have an interval
      from = Time.zone.parse(datetime['from']['value'])
      # intervals sometimes don't end!
      untill = datetime['to']['value'].blank? ? default_end : Time.zone.parse(datetime['to']['value'])
    end
    # wit.ai uses the end of a duration if grain = hour.
       # we want the start.
       # for them 1pm to 5pm == 1pm untill 6pm, including the whole of 5pm
    if datetime['to']
       untill -= 1.hour if datetime['to']['grain'] == 'hour'
       untill -= 1.minute if datetime['to']['grain'] == 'minute'
    end

    res << { from: from, untill: untill, confidence: datetime['confidence'] }
  end
  res # not yet ready to deal with multiple time windows
end



# key contexts:
# session_id: it's the person_id and the event_id, how we know what we are talking about
# reference time: the start of the event
# reference_time_slot: string of the start and end time of event
# reservation_msg: either you got a slot in your time or you didn't
# human_date: a human array of dates, joined by 'and'
access_token = ENV['WIT_ACCESS_TOKEN']
::WitClient = Wit.new access_token, actions

