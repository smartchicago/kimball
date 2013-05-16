class MailchimpExport < ActiveRecord::Base
  validates_presence_of :name, :body
  validates_length_of   :name, :in => 1..40
  
  attr_accessor :recipients  # array of email addresses to be added to the segment
  
  before_validation  :serialize_recipients_to_body
  # after_create :send_to_mailchimp

  private
  
  def serialize_recipients_to_body
    self.body = recipients.to_json
  end

  def send_to_mailchimp
    # create a new static segment    
    Gibbon.listStaticSegmentAdd(id: Logan::Application.config.cut_group_mailchimp_list_id, name: name)
    Gibbon.listStaticSegmentMembersAdd(id: Logan::Application.config.cut_group_mailchimp_list_id, seg_id: 24181, batch: recipients)
    # returns: {"success"=>2, "errors"=>[]}
  end

end
