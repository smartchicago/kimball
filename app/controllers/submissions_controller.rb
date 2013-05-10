class SubmissionsController < ApplicationController
  skip_before_filter :authenticate_user!, if: :should_skip_janky_auth?
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    email_address = params['Field113'] # FIXME: parse field definitions to find email field
    person = Person.find_by_email_address(email_address) 
    
    @submission = Submission.new(
      raw_content:      params.to_json, 
      person:           person, 
      ip_addr:          params['IP'], 
      entry_id:         params['EntryID'],
      form_structure:   params["FormStructure"],
      field_structure:  params["FieldStructure"]
    )
    
    if @submission.save
      Rails.logger.info("SubmissionsController#create: recorded a new submission for #{email_address}")
      head '201'
    else
      Rails.logger.warn("SubmissionsController#create: failed to save new submission for #{email_address}")
      head '400'
    end
  end
  
  def index
    @submissions = Submission.all.order("created_at DESC")
  end
  
  private

  def should_skip_janky_auth?
    # don't attempt authentication on reqs from wufoo
    params[:action] == 'create' && params['HandshakeKey'].present?
  end  
end