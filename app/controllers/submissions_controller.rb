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

  # GET /submission/new
  def new
    @submission = Submission.new
  end

  # GET /submission/1/edit
  def edit
  end

  # FIXME: Refactor and re-enable cop
  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
  #
  def create
    if params['HandshakeKey'].present?
      if Logan::Application.config.wufoo_handshake_key != params['HandshakeKey']
        Rails.logger.warn("[wufoo] received request with invalid handshake. Full request: #{request.inspect}")
        head(403) && return
      end

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

    else
      @submission = Submission.new(
        entry_id:          params['submission']['entry_id'],
        form_id:          params['submission']['form_id'],
        person_id:         params['submission']['person_id']
      )
      person_id = params['submission']['person_id']
      this_form_id = params['submission']['form_id']
      # Rails.logger.info "[submissions_controller create] this_form_id = #{this_form_id}"
      if this_form_id.present?
        this_form = Logan::Application.config.wufoo.form(this_form_id)
        @submission.field_structure = { 'Fields' => this_form.fields }.to_json
        @submission.form_structure = this_form.details.to_json
        raw_content = { 'FieldStructure' => @submission.field_structure }
        raw_content['FormStructure'] = @submission.form_structure
        this_entry_id = params['submission']['entry_id']
        # Rails.logger.info "[submissions_controller create] this_entry_id = #{this_entry_id}"
        if this_entry_id.present?
          this_entry = this_form.entries(filters: [['EntryId', 'Is_equal_to', this_entry_id]]).first
          # Rails.logger.info "@submission.raw_content = #{@submission.raw_content}"
          # Rails.logger.info "this_entry = #{this_entry}"
          raw_content = raw_content.merge(this_entry)
          @submission.raw_content = raw_content.to_json
        end
      end
      if @submission.save
        Rails.logger.info("SubmissionsController#create: recorded a new submission for #{person_id}")
        format.html { redirect_to submission_path, notice: 'Submission was successfully created.' }
      else
        Rails.logger.warn("SubmissionsController#create: failed to save new submission for #{person_id}")
        format.html { render action: 'new' }
      end
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize

  def index
    @submissions = Submission.all.order('created_at DESC').includes(:person)
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def submission_params
      params.require(:submission).permit(:raw_content, :person_id, :ip_addr, :entry_id, :form_structure, :field_structure, :form_id, :form_type)
    end

    def should_skip_janky_auth?
      # don't attempt authentication on reqs from wufoo
      params[:action] == 'create' && params['HandshakeKey'].present?
    end

end
