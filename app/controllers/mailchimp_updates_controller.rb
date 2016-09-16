# == Schema Information
#
# Table name: mailchimp_updates
#
#  id          :integer          not null, primary key
#  raw_content :text(65535)
#  email       :string(255)
#  update_type :string(255)
#  reason      :string(255)
#  fired_at    :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class MailchimpUpdatesController < ApplicationController
  require 'will_paginate/array'
  before_action :set_mailchimp_update, only: [:show, :edit, :update, :destroy]
  skip_before_action :authenticate_user!, if: :should_skip_janky_auth?
  skip_before_action :verify_authenticity_token, only: [:create]

  # GET /mailchimp_updates
  # GET /mailchimp_updates.json
  def index
    @mailchimp_updates = MailchimpUpdate.order('fired_at DESC').paginate(page: params[:page])
  end

  # GET /mailchimp_updates/1
  # GET /mailchimp_updates/1.json
  def show
  end

  # GET /mailchimp_updates/new
  def new
    @mailchimp_update = MailchimpUpdate.new
  end

  # GET /mailchimp_updates/1/edit
  def edit
  end

  # POST /mailchimp_updates
  # POST /mailchimp_updates.json
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    if params['mailchimpkey'].present? && params['mailchimpkey'] == ENV['MAILCHIMP_WEBHOOK_SECRET_KEY']
      @mailchimp_update = MailchimpUpdate.new(
        email:        params['data']['email'],
        update_type:  params['type'],
        fired_at:     params['fired_at'],
        raw_content:  params.to_json,
        reason:       params['data']['reason'] || nil
      )

      respond_to do |format|
        if @mailchimp_update.save
          format.html { redirect_to @mailchimp_update, notice: 'Mailchimp update was successfully created.' }
          format.json { render action: 'show', status: :created, location: @mailchimp_update }

        else
          Rails.logger.warn('MailchimpUpdatesController#create: Received new update with bad secret key.')
          head '400'
        end
      end
    end
  end

  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # PATCH/PUT /mailchimp_updates/1
  # PATCH/PUT /mailchimp_updates/1.json
  def update
    respond_to do |format|
      if @mailchimp_update.update(mailchimp_update_params)
        format.html { redirect_to @mailchimp_update, notice: 'Mailchimp update was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mailchimp_update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mailchimp_updates/1
  # DELETE /mailchimp_updates/1.json
  def destroy
    @mailchimp_update.destroy
    respond_to do |format|
      format.html { redirect_to mailchimp_updates_url }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_mailchimp_update
      @mailchimp_update = MailchimpUpdate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mailchimp_update_params
      params.require(:mailchimp_update).permit(:raw_content, :email, :update_type, :reason, :fired_at)
    end

    def should_skip_janky_auth?
      # don't attempt authentication on reqs from wufoo
      params[:action] == 'create'
    end
end
