class MailchimpExport < ActiveRecord::Base
  validates_presence_of :name, :body
  validates_length_of   :name, :in => 1..50
  
  attr_accessor :recipients  # array of email addresses to be added to the segment
  
  before_validation   :serialize_recipients_to_body
  after_create        :send_to_mailchimp

  private
  
  def serialize_recipients_to_body
    self.body = recipients.to_json
  end

  def send_to_mailchimp    
    begin
      # create a new static segment
      new_static_segment_id = Gibbon.listStaticSegmentAdd(id: Logan::Application.config.cut_group_mailchimp_list_id, name: name)

      # add the email addresses to the new static segment
      resp = Gibbon.listStaticSegmentMembersAdd(id: Logan::Application.config.cut_group_mailchimp_list_id, seg_id: new_static_segment_id, batch: recipients)

      Rails.logger.info("[MailchimpExport#send_to_mailchimp] exported #{resp['success']} email addresses to static segment named \"#{self.name}\"")
      true
    rescue StandardError => e
      Rails.logger.fatal("[MailchimpExport#send_to_mailchimp] mce_id: #{self.id} fatal error exporting to Mailchimp: #{e.message}")
      false
    end
  end

end
