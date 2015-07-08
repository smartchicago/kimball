class MailchimpExportsController < ApplicationController
  def index
    @mailchimp_exports = MailchimpExport.all    
  end


  def add_to_list(person)

  end


end
