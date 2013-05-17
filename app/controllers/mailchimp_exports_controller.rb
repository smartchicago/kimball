class MailchimpExportsController < ApplicationController
  def index
    @mailchimp_exports = MailchimpExport.all    
  end
end
