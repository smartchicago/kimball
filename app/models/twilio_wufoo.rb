# == Schema Information
#
# Table name: twilio_wufoos
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  wufoo_formid   :string(255)
#  twilio_keyword :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  status         :boolean          default(FALSE), not null
#  end_message    :string(255)
#  form_type      :string(255)
#

class TwilioWufoo < ActiveRecord::Base

  # https://robots.thoughtbot.com/inject-that-rails-configuration-dependency
  class_attribute :wufoo_form_ids
  # self.wufoo_form_ids ||= Logan::Application.config.wufoo.forms.collect { |i| [i.id, i.id] }

  validates :end_message, length: { maximum: 160 }

end
