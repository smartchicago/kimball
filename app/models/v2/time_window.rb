class V2::TimeWindow

  def initialize(date:, start_time:, end_time:, slot_length:)
    @date       = date
    @start_time = start_time
    @end_time   = end_time
    @slot_length = slot_length
    @slots      = []
  end

  # this should only return available time slots
  # and shouldn't create them
  def slots
    slot_start = start_time
    slot_end   = slot_start + slot_length

    while slot_end <= end_time
      existing_slot = ::V2::TimeSlot.where(start_time: slot_start, end_time: slot_end).first
      
      slot = ::V2::TimeSlot.new(start_time: slot_start, end_time: slot_end)

      @slots << slot unless existing_slot

      slot_start = slot_end
      slot_end   += slot_length
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
end
