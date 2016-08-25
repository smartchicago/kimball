# == Schema Information
#
# Table name: mailchimp_updates
#
#  id          :integer          not null, primary key
#  raw_content :text(65535)
#  email       :string(255)
#  update_type :string(255)
#  reason      :string(255)
#  fired_at    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe MailchimpUpdate, type: :model do
  describe 'update_person' do
    it 'creates a tag and comment for unsubscribed person' do
    end
  end
end
