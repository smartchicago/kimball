# == Schema Information
#
# Table name: mailchimp_exports
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  body       :text
#  created_by :integer
#  created_at :datetime
#  updated_at :datetime
#

class MailchimpExport < ActiveRecord::Base

  validates_presence_of :name, :body
  validates_length_of   :name, in: 1..50

  attr_accessor :recipients # array of email addresses to be added to the segment

  before_validation   :serialize_recipients_to_body
  after_create        :send_to_mailchimp

  private

    def serialize_recipients_to_body
      self.body = recipients.to_json
    end

    def send_to_mailchimp
      # create a new static segment
      #new_static_segment_id = Gibbon.listStaticSegmentAdd(id: Logan::Application.config.cut_group_mailchimp_list_id, name: name)

      # add the email addresses to the new static segment
      #resp = Gibbon.listStaticSegmentMembersAdd(id: Logan::Application.config.cut_group_mailchimp_list_id, seg_id: new_static_segment_id, batch: recipients)

      # New API 3.0 version:
      gibbon = Gibbon::Request.new
      resp = gibbon.lists(Logan::Application.config.cut_group_mailchimp_list_id).segments.create( body: { name: name, static_segment: recipients})

      Rails.logger.info("[MailchimpExport#send_to_mailchimp] exported #{resp['success']} email addresses to static segment named \"#{name}\"")
      true
    rescue StandardError => e
      Rails.logger.fatal("[MailchimpExport#send_to_mailchimp] mce_id: #{id} fatal error exporting to Mailchimp: #{e.message}")
      false
    end

end
