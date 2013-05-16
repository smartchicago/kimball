class MailchimpExportsController < ApplicationController
  def index
    @mailchimp_exports = MailchimpExport.all    
  end

  def create
    @mailchimp_export = MailchimpExport.new(name: params[:mailchimp_export][:name], recipients: params[:mailchimp_export][:recipients])
    
    if @mailchimp_export.save
      respond_to do |format|
        format.js { } 
      end
    else
      respond_to do |format|
        Rails.logger.debug("error: ")
        format.all { render text: "invalid request. #{@mailchimp_export.errors.inspect}", status: 400 } 
      end      
    end
  end
end
