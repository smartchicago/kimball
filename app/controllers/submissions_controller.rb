# == Schema Information
#
# Table name: submissions
#
#  id              :integer          not null, primary key
#  raw_content     :text(65535)
#  person_id       :integer
#  ip_addr         :string(255)
#  entry_id        :string(255)
#  form_structure  :text(65535)
#  field_structure :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#

class SubmissionsController < ApplicationController

  skip_before_action :authenticate_user!, if: :should_skip_janky_auth?
  skip_before_action :verify_authenticity_token, only: [:create]

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength
  #
  def create
    @submission = Submission.new(
      raw_content:      params.to_json,
      ip_addr:          params['IP'],
      entry_id:         params['EntryId'],
      form_structure:   params['FormStructure'],
      field_structure:  params['FieldStructure']
    )

    # Parse the email, and add the associated person
    email_address = @submission.form_email || nil
    @submission.person = Person.find_by_email_address(email_address)

    if @submission.save
      Rails.logger.info("SubmissionsController#create: recorded a new submission for #{email_address}")
      head '201'
    else
      Rails.logger.warn("SubmissionsController#create: failed to save new submission for #{email_address}")
      head '400'
    end
  end
  # rubocop:enable Metrics/MethodLength

  def index
    @submissions = Submission.all.order('created_at DESC')
  end

  private

    def should_skip_janky_auth?
      # don't attempt authentication on reqs from wufoo
      params[:action] == 'create' && params['HandshakeKey'].present?
    end

end
