module ApplicationHelper
  def simple_time_select_options
    minutes = %w( 00 15 30 45 )
    hours = (0..23).to_a.map { |h| format('%.2d', h) }
    options = hours.map do |h|
      minutes.map { |m| "#{h}:#{m}" }
    end.flatten
    options_for_select(options)
  end
end
