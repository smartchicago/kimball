class TwilioWufoo < ActiveRecord::Base
	validates :end_message, length: { maximum: 160 }
end
