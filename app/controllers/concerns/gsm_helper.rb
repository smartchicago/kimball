module GsmHelper

  # FIXME: refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength
  #
  # Returns a new string in GSM 03.38 encoding
  def to_gsm0338(message)
    # Replace bad characters with GSM allowed ones
    map =
      {
        '“' => '"',
        '”' => '"',
        '—' => '-',
        '’' => "'",
        '$' => '$'
      }
    re = Regexp.new(map.keys.map { |x| Regexp.escape(x) }.join('|'))

    message_clean = message.gsub(re, map)
    if message_clean.present?
      # Run resulting string though GSMEncoder. Replace any remaining bad characters with a space.
      # message_clean = GSMEncoder.encode(message_clean, ' ')
      message_clean = message_clean.gsub(/\s\\x02/, '$')

    end
    message_clean
  end
  # rubocop:enable Metrics/MethodLength

end
