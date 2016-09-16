# requests from Wufoo will include this token to prove authenticity
Logan::Application.config.wufoo_handshake_key = ENV['WUFOO_HANDSHAKE_KEY']

Logan::Application.config.wufoo = WuParty.new(ENV['WUFOO_ACCOUNT'], ENV['WUFOO_API'])