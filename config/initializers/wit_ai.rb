require 'wit'

access_token = ENV['WIT_ACCESS_TOKEN']

# note, context: it's a hash with string keys. allways string keys
# that's because we save it in json in redis for reuse
actions = {
  say: lambda do |_session_id, context, msg|
    # this is where we text.
    person = Person.find_by(id: context['person_id'])
    ::WitSms.new(to: person, msg: msg).send
  end,
  merge: lambda do |_session_id, context, entities, _msg|
    # not sure what else we'd do here.
    # maybe some content munging to make things easier?
    # like make our dates nice and pretty etc.

    # state is usefull for setting up the initial yes_or_no
    context.delete('state') if context['state']
    return context.merge(entities)
  end,
  error: lambda do |_session_id, _context, error|
    p error.message
  end,
  get_event: lambda do |_session_id, context|
    # session ID and context will have event id in it.
    ei = V2::EventInvitation.find_by(id: context['event_id'])

    context.merge({ 'reference_time' => ei.start_datetime,
                    'reference_time_slot' =>  ei.bot_duration })
  end,
  select_slot_in_time: lambda do |_session_id, context|
    # currently unused
    context.merge({ 'first_slot_in_time' => 'friday at 2pm' })
  end,
  reserve_slot: lambda do |_session_id, context|
    # datetime is the time the person chose.

    pp context
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
        msg = "A #{duration} minute interview has been booked for:\n#{selected_time}\nWith: #{r.user.name}, \nTel: #{r.user.phone_number}\n.You'll get a reminder that morning."
      else
        msg = 'It appears there are no more times available. There will be more opportunities soon!'
      end
      Redis.current.del("wit_context:#{person.id}")
      context.merge({ 'response_msg' => msg })
    else
      context.merge({ 'response_msg' => "I'm sorry, I'm just a silly robot. I didn't understand that. Please respond with something that looks like: #{context['reference_time_slot']}" })
    end
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
    # probably destroy the context and turn end the current session
    context
  end
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
    else
      from = Time.zone.parse(datetime['from']['value'])
      # wit.ai uses the end of a duration. we want the start.
      # for them 1pm to 5pm == 1pm untill 6pm, including the whole of 5pm
      untill =  Time.zone.parse(datetime['to']['value']) - 1.hour
    end
    res << { from: from, untill: untill, confidence: datetime['confidence'] }
  end
  res # not yet ready to deal with multiple time windows
end


# key contexts:
# session_id: it's the person_id and the event_id, how we know what we are talking about
# reference time: the start of the event
# reference_time_slot: string of the start and end time of event
# response_msg: either you got a slot in your time or you didn't
#
::WitClient = Wit.new access_token, actions

