# == Schema Information
#
# Table name: twilio_messages
#
#  id                 :integer          not null, primary key
#  message_sid        :string(255)
#  date_created       :datetime
#  date_updated       :datetime
#  date_sent          :datetime
#  account_sid        :string(255)
#  from               :string(255)
#  to                 :string(255)
#  body               :string(255)
#  status             :string(255)
#  error_code         :string(255)
#  error_message      :string(255)
#  direction          :string(255)
#  from_city          :string(255)
#  from_state         :string(255)
#  from_zip           :string(255)
#  wufoo_formid       :string(255)
#  conversation_count :integer
#  signup_verify      :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class TwilioMessage < ActiveRecord::Base

  phony_normalize :to, default_country_code: 'US'
  phony_normalized_method :to, default_country_code: 'US'

  phony_normalize :from, default_country_code: 'US'
  phony_normalized_method :from, default_country_code: 'US'

  self.per_page = 15

end
