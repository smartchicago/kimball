# == Schema Information
#
# Table name: mailchimp_exports
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  body       :text(65535)
#  created_by :integer
#  created_at :datetime
#  updated_at :datetime
#

class MailchimpExportsController < ApplicationController

  def index
    @mailchimp_exports = MailchimpExport.all
  end

end
