class V2::TimeWindow

  # rubocop:disable Metrics/ParameterLists
  def initialize(date:, start_time:, end_time:, slot_length:, event_id:, buffer: 0)
    @date       = date
    @start_time = start_time
    @end_time   = end_time
    @slot_length = slot_length
    @slots      = []
    @buffer     = buffer
    @event_id   = event_id
  end
  # rubocop:enable Metrics/ParameterLists

  # this should only return available time slots
  # and shouldn't create them
  def slots
    slot_start = start_time
    slot_end   = slot_start + slot_length
    while slot_end <= end_time
      slot = ::V2::TimeSlot.new(start_time: slot_start, end_time: slot_end, event_id: @event_id)
      @slots << slot if slot.valid?
      slot_start = slot_end + buffer
      slot_end   = slot_start + slot_length
    end

    @slots
  end

  private

    def date
      Date.strptime(@date, '%m/%d/%Y')
    end

    def start_time
      Time.zone.parse("#{date} #{@start_time}")
    end

    def end_time
      Time.zone.parse("#{date} #{@end_time}")
    end

    def slot_length
      @slot_length.delete(' mins').to_i.minutes
    end

    def buffer
      @buffer.to_i.minutes
    end
end
